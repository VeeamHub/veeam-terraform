<#
.SYNOPSIS
deploy_veeam_sddc_release.ps1
.DESCRIPTION
#>

[CmdletBinding()]

    Param
    (
        [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
        [Switch]$RunAll,

        [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
        [Switch]$RunVBRDeployOnly,

        [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
        [Switch]$RunAWSDeploy,

        [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
        [Switch]$RunVBRConfigure,

        [Parameter(Mandatory=$false,
         ValueFromPipelineByPropertyName=$true)]
        [Switch]$LocalLinuxRepoDeploy,

        [Parameter(Mandatory=$false,
         ValueFromPipelineByPropertyName=$true)]
        [Switch]$CloudConnectNEA,

        [Parameter(Mandatory=$false,
         ValueFromPipelineByPropertyName=$true)]
        [Switch]$NoCloudConnect,

        [Parameter(Mandatory=$false,
         ValueFromPipelineByPropertyName=$true)]
        [Switch]$CloudConnectOnly,

        [Parameter(Mandatory=$false,
         ValueFromPipelineByPropertyName=$true)]
        [Switch]$NoLinuxRepo,

        [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
        [Switch]$NoDefaultJobs,

        [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
        [Switch]$ConfigureSOBR,

        [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
        [Switch]$NoCapacityTier,

        [Parameter(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
        [Switch]$ClearVBRConfig
    )

if (!$RunAll -and !$RunVBRDeployOnly -and !$RunAWSDeploy -and !$RunVBRConfigure -and !$LocalLinuxRepoDeploy -and !$ClearVBRConfig)
    {
        Write-Host ""
        Write-Host ":: - ERROR! Script was run without using a parameter..." -ForegroundColor Red -BackgroundColor Black
        Write-Host ":: - Please use: -RunAll, -RunVBRDeployOnly, -RunAWSDeployVBRConfigure or -RunVBRConfigure or -ClearVBRConfig" -ForegroundColor Yellow -BackgroundColor Black 
        Write-Host ""
        break
    }

$StartTime = Get-Date

#To be run on Server Isntalled with Veeam Backup & Replicaton
if (!(get-pssnapin -name VeeamPSSnapIn -erroraction silentlycontinue)) 
        {
         add-pssnapin VeeamPSSnapIn
        }

#Check for VMware PowerCLI and Install and Import if missing
if (!(Get-Module VMware.PowerCLI -erroraction silentlycontinue)) 
        {
        #Install-Module VMware.PowerCLI -Force | Out-Null
        Import-Module VMware.PowerCLI | Out-Null
        }

#Get Variables from Master Config
$config = Get-Content config.json | ConvertFrom-Json

function Pause
    {
        write-Host ""
        write-Host ":: Press Enter to continue..." -ForegroundColor Yellow -BackgroundColor Black
        Read-Host | Out-Null 
    }

function Run-TerraformChefBuild 
    {
        $host.ui.RawUI.WindowTitle = "Deploying Veeam Backup & Replication Server with Terraform and Chef"
        
        $wkdir = Get-Location
        Set-Location -Path $config.Default.ChefPath
        & .\terraform.exe apply -auto-approve
        write-Host ":: Backup & Replication Server Rebooted" -ForegroundColor Yellow -BackgroundColor Black
        Start-Sleep 10
        & .\terraform.exe apply -auto-approve
        & .\terraform.exe output -json vbr_host > $config.Default.TFOutputVBR
        #Pause
        Write-Host ":: Adding two additional Proxies to Backup & Replication in background" -ForegroundColor Green
        invoke-command  -scriptblock {cd $config.Default.ChefPath;.\terraform.exe apply -var proxy_count=2 --auto-approve} -AsJob -computer $env:computername  
        Set-Location $wkdir
    }

function Run-TerraformAWSBuild 
    {
        $host.ui.RawUI.WindowTitle = "Creating AWS VPC and a Veeam Linux Repo plus Veeam PN instance with Terraform"
        
        $wkdir = Get-Location
        Set-Location -Path $config.Default.AWSDeployPath
        & .\terraform.exe apply -auto-approve
        & .\terraform.exe output -json private_ip_VeeamRepo > $config.Default.LinuxRepoIP
        Set-Location $wkdir
    }

function Run-LinuxRepoBuild
    {
        $host.ui.RawUI.WindowTitle = "Deploying Local Veeam Linux Repo with Terraform"
        
        $wkdir = Get-Location
        Set-Location -Path $config.Default.LinuxRepoBuildPath
        & .\terraform.exe apply -auto-approve
        & .\terraform.exe output -json vsphere_ipv4_address > $config.Default.LinuxRepoIP
        Set-Location $wkdir
    }

function Connect-VBR-Server
    {
        #Connect to the Backup & Replication Server
        $ChefVBR = Get-Content $config.Default.TFOutputVBR | ConvertFrom-Json
        Disconnect-VBRServer
        Connect-VBRServer -Server $ChefVBR.value -user $config.VBRCredentials.Username -password $config.VBRCredentials.Password 
    }

function Add-vCenter    
    {
        Write-Host ":: Adding vCenter to Backup & Replication" -ForegroundColor Green
        Remove-VBRServer $config.VMCCredentials.vCenter -Confirm:$false
        Add-VBRvCenter -Name $config.VMCCredentials.vCenter -User $config.VMCCredentials.Username -Password $config.VMCCredentials.Password -WarningAction SilentlyContinue | Out-Null     
    }

    function Add-VCC-Provider 
    {
        $host.ui.RawUI.WindowTitle = "Adding Cloud Connect Service Provider"
        
        #Add Cloud Connect User Account from Service Provider
        Write-Host ":: Adding Cloud Connect Tenant to Stored Credentials" -ForegroundColor Green
        Add-VBRCloudProviderCredentials -Name $config.VCCProvider.CCUserName -Password $config.VCCProvider.CCPassword -Description $config.VCCProvider.CCUserName

        #Set the Cloud Connect User Account credentials
        $credentials = Get-VBRCloudProviderCredentials -Name $config.VCCProvider.CCUserName

        #Add the Cloud Provider into Veeam Backup & Replication
        Write-Host ":: Adding Cloud Connect Service Provider Endpoint and Backup Repository" -ForegroundColor Green
        Add-VBRCloudProvider -Address $config.VCCProvider.CCServerAddress -Port $config.VCCProvider.CCPort -VerifyCertificate:$false -Credentials $credentials -Force -WarningAction SilentlyContinue | Out-Null
    }

function Add-Linux-Repo 
    {
        $host.ui.RawUI.WindowTitle = "Configuring Veeam Linux Repository"

        Start-Sleep 5
        #Get AWS EC2 Repo Internal IP from Terraform output
        $IPAddress = Get-Content $config.Default.LinuxRepoIP | ConvertFrom-json 

        #Get Variables from Master Config
        $config = Get-Content config.json | ConvertFrom-Json

        if (!$LocalLinuxRepoDeploy)
            {
                #Add Linux Public Key Credential
                Add-VBRCredentials -Type LinuxPubKey -User $config.LinuxRepo.Username -PrivateKeyPath $config.LinuxRepo.Key -Password "" -ElevateToRoot | Out-Null

                #Get Linux Credential
                $LinuxCredential = Get-VBRCredentials -Name $config.LinuxRepo.Username

                #Add Linux Instance to Backup & Replication
                Write-Host ":: Adding Linux Server to Backup & Replication" -ForegroundColor Green
                Add-VBRLinux -Name $IPAddress.value -Description "AWS Linux Repository" -Credentials $LinuxCredential -WarningAction SilentlyContinue | Out-Null

                #Add Linux Repository to Backup & Replication
                Write-Host ":: Creating New Linux Backup Repository" -ForegroundColor Green
                Add-VBRBackupRepository -Name $config.LinuxRepo.RepoName -Description "AWS Linux Repository" -Type LinuxLocal -Server $IPAddress.value -Folder $config.LinuxRepo.RepoFolder -Credentials $LinuxCredential | Out-Null
            }

        if ($LocalLinuxRepoDeploy)
            {
               #Add Linux Public Key Credential
               Add-VBRCredentials -Type Linux -User $config.LinuxRepo.LocalUsername -Password $config.LinuxRepo.LocalPassword -ElevateToRoot -Description $config.LinuxRepo.LocalRepoName  | Out-Null

               #Get Linux Credential
               $LinuxCredential = Get-VBRCredentials | where {$_.Description -eq $config.LinuxRepo.LocalRepoName}

               #Add Linux Instance to Backup & Replication
               Write-Host ":: Adding Linux Server to Backup & Replication" -ForegroundColor Green
               Add-VBRLinux -Name $IPAddress.value -Description "Local Linux Repository" -Credentials $LinuxCredential -WarningAction SilentlyContinue | Out-Null

               #Add Linux Repository to Backup & Replication
               Write-Host ":: Creating New Linux Backup Repository" -ForegroundColor Green
               Add-VBRBackupRepository -Name $config.LinuxRepo.LocalRepoName -Description "Local Linux Repository" -Type LinuxLocal -Server $IPAddress.value -Folder $config.LinuxRepo.RepoFolder -Credentials $LinuxCredential | Out-Null 
            }
        }

        function Add-SOBR
        {
            $host.ui.RawUI.WindowTitle = "Configuring Veeam SOBR Repository"

            if($LocalLinuxRepoDeploy)
                {
                $RepoExtent1 = $config.LinuxRepo.LocalRepoName
                }
            else 
                {
                $RepoExtent1 = $config.LinuxRepo.RepoName 
                }
            
            #Configure Capacity Tier with Amazon S3
            if(!$NoCapacityTier)
                {
                    #Add AWS Account Credentials
                    Add-VBRAmazonAccount -AccessKey $config.SOBRRepo.AWSAccessKey -SecretKey $config.SOBRRepo.AWSSecretKey | Out-Null
                    
                    #Set AWS Account Variables
                    $AWSAccount = Get-VBRAmazonAccount
                    $AWSConnection = Connect-VBRAmazonS3Service -Account $AWSAccount -RegionType Global -ServiceType CapacityTier
                    $AWSBucket = Get-VBRAmazonS3Bucket -Connection $AWSConnection -Name $config.SOBRRepo.S3Bucket
                            
                    #Create new Amazon S3 Folder
                    New-VBRAmazonS3Folder -Connection $AWSConnection -Bucket $AWSBucket -Name $config.SOBRRepo.S3Folder | Out-Null
            
                    $AWSFolder = Get-VBRAmazonS3Folder -Connection $AWSConnection -Bucket $AWSBucket -Name $config.SOBRRepo.S3Folder
            
                    #Add new Amazon S3 backed Object Storage Repository
                    Add-VBRAmazonS3Repository -Name $config.SOBRRepo.ObjectStorageRepoName -AmazonS3Folder $AWSFolder -Connection $AWSConnection -EnableSizeLimit -SizeLimit $config.SOBRRepo.ObjectStorageRepoLimit | Out-Null
                }
    
            $VBRServer = Get-VBRServer -Name $config.VBRCredentials.VBRServer
    
            #Add SOBR with or without Capacity Teir
            if(!$NoCapacityTier)
                {
                    Add-VBRScaleOutBackupRepository -Name $config.SOBRRepo.RepoName -PolicyType DataLocality -Extent $RepoExtent1 -UsePerVMBackupFiles -EnableCapacityTier -ObjectStorageRepository $config.SOBRRepo.ObjectStorageRepoName -OperationalRestorePeriod $config.SOBRRepo.RestoreWindow | Out-Null
                }
            else
                {
                    Add-VBRScaleOutBackupRepository -Name $config.SOBRRepo.RepoName -PolicyType DataLocality -Extent $RepoExtent1 -UsePerVMBackupFiles | Out-Null
                }
        }

function Create-vSphereTags

        {
            $host.ui.RawUI.WindowTitle = "Creating vCenter Tags"
    
            Connect-VIServer -Server $config.VMCCredentials.vCenter -User $config.VMCCredentials.Username -Password $config.VMCCredentials.Password -Force | Out-Null
            
            Write-Host ":: Creating VMware Tag Catagories" -ForegroundColor Green
            New-TagCategory -Name $config.VBRJobDetails.TagCatagory1 -Cardinality "Single" -EntityType "VirtualMachine" -Description "Backup Jobs Policy Tag" | Out-Null
            New-TagCategory -Name $config.VBRJobDetails.TagCatagory2 -Cardinality "Single" -EntityType "VirtualMachine" -Description "Backup Jobs Policy Tag" | Out-Null
            
            Write-Host ":: Creating VMware Tags" -ForegroundColor Green
            New-Tag -Name $config.VBRJobDetails.Tag1 -Category $config.VBRJobDetails.TagCatagory2 | Out-Null
            New-Tag -Name $config.VBRJobDetails.Tag2 -Category $config.VBRJobDetails.TagCatagory1 | Out-Null
            New-Tag -Name $config.VBRJobDetails.Tag3 -Category $config.VBRJobDetails.TagCatagory1 | Out-Null
        }

function Create-VBRJobs
    {   
        $host.ui.RawUI.WindowTitle = "Creating vCenter Tags and Veeam Backup & Replication Jobs"
      
        if (!$NoLinuxRepo -and !$NoCloudConnect)
            {
                $BackupRepo1 = $config.SOBRRepo.RepoName
                $BackupRepo2 = $config.VCCProvider.CCRepoName
            }
        elseif ($NoLinuxRepo -and !$NoCloudConnect)
            {
                $BackupRepo1 = $config.VBRJobDetails.DefaultRepo1
                $BackupRepo2 = $config.VCCProvider.CCRepoName  
            }
        elseif (!$NoLinuxRepo -and $NoCloudConnect)
            {
                $BackupRepo1 = $config.SOBRRepo.RepoName
                $BackupRepo2 = $config.VBRJobDetails.DefaultRepo1 
            }
        elseif (!$LocalLinuxRepoDeploy) 
            {
                $BackupRepo1 = $config.LinuxRepo.RepoName
            }    
        elseif ($LocalLinuxRepoDeploy) 
            {
                $BackupRepo1 = $config.SOBRRepo.RepoName
            }  
        else
            {
                $BackupRepo1 = $config.VBRJobDetails.DefaultRepo1
                $BackupRepo2 = $config.VBRJobDetails.DefaultRepo1   
            }
               
        Write-Host ":: Creating Tag Based Policy Backup Job 1" -ForegroundColor Green
        Add-VBRViBackupJob -Name $config.VBRJobDetails.Job2 -BackupRepository $BackupRepo1 -Entity (Find-VBRViEntity -Tags -Name $config.VBRJobDetails.Tag2) | Out-Null
        Write-Host ":: Creating Tag Based Policy Backup Job 2" -ForegroundColor Green
        Add-VBRViBackupJob -Name $config.VBRJobDetails.Job3 -BackupRepository $BackupRepo2 -Entity (Find-VBRViEntity -Tags -Name $config.VBRJobDetails.Tag3) | Out-Null
        
        Write-Host ":: Setting Retention Policy Backup Jobs" -ForegroundColor Green
        $JobOptions = Get-VBRJobOptions $config.VBRJobDetails.Job2
        $JobOptions.BackupStorageOptions.RetainCycles = $config.VBRJobDetails.RestorePoints1 
        $config.VBRJobDetails.Job2 | Set-VBRJobOptions -Options $JobOptions | Out-Null

        $JobOptions = Get-VBRJobOptions $config.VBRJobDetails.Job3
        $JobOptions.BackupStorageOptions.RetainCycles = $config.VBRJobDetails.RestorePoints2
        $config.VBRJobDetails.Job3 | Set-VBRJobOptions -Options $JobOptions | Out-Null
        
        Get-VBRJob -Name $config.VBRJobDetails.Job2 | Set-VBRJobAdvancedBackupOptions -Algorithm Incremental -TransformFullToSyntethic $False -EnableFullBackup $True -FullBackupDays $config.VBRJobDetails.FullDay | Out-Null
        Get-VBRJob -Name $config.VBRJobDetails.Job3 | Set-VBRJobAdvancedBackupOptions -Algorithm Incremental -TransformFullToSyntethic $False -EnableFullBackup $True -FullBackupDays $config.VBRJobDetails.FullDay | Out-Null
        
        Write-Host ":: Setting Schedule for Backup Jobs" -ForegroundColor Green
        Get-VBRJob -Name $config.VBRJobDetails.Job2 | Set-VBRJobSchedule -Daily -At $config.VBRJobDetails.Time1 | Out-Null
        Get-VBRJob -Name $config.VBRJobDetails.Job2 | Enable-VBRJobSchedule | Out-Null

        Write-Host ":: Enabling Backup Jobs" -ForegroundColor Green
        Get-VBRJob -Name $config.VBRJobDetails.Job3 | Set-VBRJobSchedule -Daily -At $config.VBRJobDetails.Time2 | Out-Null
        Get-VBRJob -Name $config.VBRJobDetails.Job3 | Enable-VBRJobSchedule | Out-Null
    }

function ClearVBRConfig
    {
        #Clear all the Backup & Replication Configuration

        $host.ui.RawUI.WindowTitle = "Clearing the Veeam Backup & Replication Configuration"

        Connect-VBR-Server
        
        $config = Get-Content config.json | ConvertFrom-Json
        $IPAddress = Get-Content $config.Default.LinuxRepoIP | ConvertFrom-json
        $ChefVBR = Get-Content vbr_ip.json | ConvertFrom-Json

        #Clear Jobs
        Get-VBRJob -Name $config.VBRJobDetails.Job1 | Remove-VBRJob -Confirm:$false -WarningAction SilentlyContinue | Out-Null
        Get-VBRJob -Name $config.VBRJobDetails.Job2 | Remove-VBRJob -Confirm:$false -WarningAction SilentlyContinue | Out-Null
        Get-VBRJob -Name $config.VBRJobDetails.Job3 | Remove-VBRJob -Confirm:$false -WarningAction SilentlyContinue | Out-Null

        #Clear Linux Repo and Server
        Get-VBRBackupRepository -ScaleOut -Name $config.SOBRRepo.RepoName | Remove-VBRBackupRepository -Confirm:$false -WarningAction SilentlyContinue | Out-Null
        Get-VBRBackupRepository -Name $config.LinuxRepo.RepoName | Remove-VBRBackupRepository -Confirm:$false -WarningAction SilentlyContinue | Out-Null
        Get-VBRBackupRepository -Name $config.LinuxRepo.LocalRepoName | Remove-VBRBackupRepository -Confirm:$false -WarningAction SilentlyContinue | Out-Null
        Get-VBRObjectStorageRepository -Name $config.SOBRRepo.ObjectStorageRepoName | Remove-VBRObjectStorageRepository -Confirm:$false -WarningAction SilentlyContinue | Out-Null
        Get-VBRServer -Type Linux -Name $IPAddress.value | Remove-VBRServer -Confirm:$false -WarningAction SilentlyContinue | Out-Null

        #Clear Cloud Connect Provider
        Get-VBRCloudProvider -Name $config.VCCProvider.CCServerAddress | Remove-VBRCloudProvider -Confirm:$false -WarningAction SilentlyContinue | Out-Null

        #Clear vCenter Server
        Get-VBRServer -Type VC -Name $config.VMCCredentials.vCenter | Remove-VBRServer -Confirm:$false -WarningAction SilentlyContinue | Out-Null

        #Clear Credentials
        Get-VBRCredentials -Name $config.VMCCredentials.Username | Remove-VBRCredentials -Confirm:$false -WarningAction SilentlyContinue | Out-Null
        Get-VBRCloudProviderCredentials -Name $config.VCCProvider.CCUserName | Remove-VBRCloudProviderCredentials -Confirm:$false -WarningAction SilentlyContinue | Out-Null
        Get-VBRCredentials -Name $config.LinuxRepo.Username | Remove-VBRCredentials -Confirm:$false -WarningAction SilentlyContinue | Out-Null
        Get-VBRCredentials | where {$_.Description -eq $config.LinuxRepo.LocalRepoName} | Remove-VBRCredentials -Confirm:$false -WarningAction SilentlyContinue | Out-Null
        Get-VBRAmazonAccount -AccessKey $config.SOBRRepo.AWSAccesskey | Remove-VBRAmazonAccount -Confirm:$false -WarningAction SilentlyContinue | Out-Null

        #Clear vCenter Tags
        get-tag $config.VBRJobDetails.Tag1 | Remove-Tag -Confirm:$false | Out-Null
        get-tag $config.VBRJobDetails.Tag2 | Remove-Tag -Confirm:$false | Out-Null
        get-tag $config.VBRJobDetails.Tag3 | Remove-Tag -Confirm:$false | Out-Null
        
        Get-TagCategory $config.VBRJobDetails.TagCatagory1 | Remove-TagCategory -Confirm:$false | Out-Null
        Get-TagCategory $config.VBRJobDetails.TagCatagory2 | Remove-TagCategory -Confirm:$false | Out-Null
    }

#Execute Functions

if ($RunAll){
    #Run the code for run all

    $StartTimeCF = Get-Date
    Run-TerraformChefBuild
    Write-Host ""
    Write-Host ":: - Backup & Replication Server Deployed via Chef - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeCF = Get-Date
    $durationCF = [math]::Round((New-TimeSpan -Start $StartTimeCF -End $EndTimeCF).TotalMinutes,2)
    Write-Host "Execution Time" $durationCF -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
    
    if (!$LocalLinuxRepoDeploy)
        {
            $StartTimeRT = Get-Date
            Run-TerraformAWSBuild
            Write-Host ""
            Write-Host ":: - AWS Repository and VeeamPN SiteGateway Deployed - ::" -ForegroundColor Green -BackgroundColor Black
            $EndTimeRT = Get-Date
            $durationRT = [math]::Round((New-TimeSpan -Start $StartTimeRT -End $EndTimeRT).TotalMinutes,2)
            Write-Host "Execution Time" $durationRT -ForegroundColor Green -BackgroundColor Black
            Write-Host "" 
        }

    if ($LocalLinuxRepoDeploy)
        {
            $StartTimeRT = Get-Date
            Run-LinuxRepoBuild
            Write-Host ""
            Write-Host ":: - Local Veema Linux Repository Deployed - ::" -ForegroundColor Green -BackgroundColor Black
            $EndTimeRT = Get-Date
            $durationRT = [math]::Round((New-TimeSpan -Start $StartTimeRT -End $EndTimeRT).TotalMinutes,2)
            Write-Host "Execution Time" $durationRT -ForegroundColor Green -BackgroundColor Black
            Write-Host "" 
        }
    
    $StartTimeVB = Get-Date
    Connect-VBR-Server
    Write-Host ""
    Write-Host ":: - Connected to Backup & Replication Server - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeVB = Get-Date
    $durationVB = [math]::Round((New-TimeSpan -Start $StartTimeVB -End $EndTimeVB).TotalMinutes,2)
    Write-Host "Execution Time" $durationVB -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
    
    $StartTimeVC = Get-Date
    Add-vCenter
    Write-Host ""
    Write-Host ":: - vCenter added to Backup & Replication - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeVC = Get-Date
    $durationVC = [math]::Round((New-TimeSpan -Start $StartTimeVC -End $EndTimeVC).TotalMinutes,2)
    Write-Host "Execution Time" $durationVC -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
    
    $StartTimeVCC = Get-Date
    Add-VCC-Provider
    Write-Host ""
    Write-Host ":: - Veeam Cloud Connect Service Provider Configured - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeVCC = Get-Date
    $durationVCC = [math]::Round((New-TimeSpan -Start $StartTimeVCC -End $EndTimeVCC).TotalMinutes,2)
    Write-Host "Execution Time" $durationVCC -ForegroundColor Green -BackgroundColor Black
    Write-Host ""

    $StartTimeLR = Get-Date
    Add-Linux-Repo
    Write-Host ""
    Write-Host ":: - Veeam Linux Repository Configured - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeLR = Get-Date
    $durationLR = [math]::Round((New-TimeSpan -Start $StartTimeLR -End $EndTimeLR).TotalMinutes,2)
    Write-Host "Execution Time" $durationLR -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
    
    $StartTimeSR = Get-Date
    Add-SOBR
    Write-Host ""
    Write-Host ":: - Veeam SOBR Repository Configured - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeSR = Get-Date
    $durationSR = [math]::Round((New-TimeSpan -Start $StartTimeSR -End $EndTimeSR).TotalMinutes,2)
    Write-Host "Execution Time" $durationLR -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
    
    $StartTimeTG = Get-Date
    Create-vSphereTags
    Write-Host ""
    Write-Host ":: - vSphere Tags Created - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeTG = Get-Date
    $durationTG = [math]::Round((New-TimeSpan -Start $StartTimeTG -End $EndTimeTG).TotalMinutes,2)
    Write-Host "Execution Time" $durationTG -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
    
    $StartTimeJB = Get-Date
    Create-VBRJobs
    Write-Host ""
    Write-Host ":: - Backup Jobs Configured - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeJB = Get-Date
    $durationJB = [math]::Round((New-TimeSpan -Start $StartTimeJB -End $EndTimeJB).TotalMinutes,2)
    Write-Host "Execution Time" $durationJB -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
}

if ($RunVBRDeployOnly){
    #Run the code for VBR DeployOnly

    $StartTimeCF = Get-Date
    Run-TerraformChefBuild
    Write-Host ""
    Write-Host ":: - Backup & Replication Server Deployed via Chef - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeCF = Get-Date
    $durationCF = [math]::Round((New-TimeSpan -Start $StartTimeCF -End $EndTimeCF).TotalMinutes,2)
    Write-Host "Execution Time" $durationCF -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
}

if ($RunAWSDeploy){
    #Rune the code for AWS Deploy

    $StartTimeRT = Get-Date
    Run-TerraformAWSBuild
    Write-Host ""
    Write-Host ":: - AWS Repository and VeeamPN SiteGateway Deployed - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeRT = Get-Date
    $durationRT = [math]::Round((New-TimeSpan -Start $StartTimeRT -End $EndTimeRT).TotalMinutes,2)
    Write-Host "Execution Time" $durationRT -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
}

if ($LocalLinuxRepoDeploy -and $RunVBRConfigure){
    #Run the code for Local Linux Deploy

    $StartTimeRT = Get-Date
    Run-LinuxRepoBuild
    Write-Host ""
    Write-Host ":: - Local Veema Linux Repository Deployed - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeRT = Get-Date
    $durationRT = [math]::Round((New-TimeSpan -Start $StartTimeRT -End $EndTimeRT).TotalMinutes,2)
    Write-Host "Execution Time" $durationRT -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
}

if ($RunVBRConfigure){
    #Run the code for VBR configure

    $StartTimeVB = Get-Date
    Connect-VBR-Server
    Write-Host ""
    Write-Host ":: - Connected to Backup & Replication Server - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeVB = Get-Date
    $durationVB = [math]::Round((New-TimeSpan -Start $StartTimeVB -End $EndTimeVB).TotalMinutes,2)
    Write-Host "Execution Time" $durationVB -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
    
    $StartTimeVC = Get-Date
    Add-vCenter
    Write-Host ""
    Write-Host ":: - vCenter added to Backup & Replication - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeVC = Get-Date
    $durationVC = [math]::Round((New-TimeSpan -Start $StartTimeVC -End $EndTimeVC).TotalMinutes,2)
    Write-Host "Execution Time" $durationVC -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
    
    if (!$NoCloudConnect)
        {
            $StartTimeVCC = Get-Date
            Add-VCC-Provider
            Write-Host ""
            Write-Host ":: - Veeam Cloud Connect Service Provider Configured - ::" -ForegroundColor Green -BackgroundColor Black
            $EndTimeVCC = Get-Date
            $durationVCC = [math]::Round((New-TimeSpan -Start $StartTimeVCC -End $EndTimeVCC).TotalMinutes,2)
            Write-Host "Execution Time" $durationVCC -ForegroundColor Green -BackgroundColor Black
            Write-Host ""
        }
    
    if (!$NoLinuxRepo)
        {  
            $StartTimeLR = Get-Date
            Add-Linux-Repo
            Write-Host ""
            Write-Host ":: - Veeam Linux Repository Configured - ::" -ForegroundColor Green -BackgroundColor Black
            $EndTimeLR = Get-Date
            $durationLR = [math]::Round((New-TimeSpan -Start $StartTimeLR -End $EndTimeLR).TotalMinutes,2)
            Write-Host "Execution Time" $durationLR -ForegroundColor Green -BackgroundColor Black
            Write-Host ""
        }

    if ($ConfigureSOBR)
        {
            $StartTimeSR = Get-Date
            Add-SOBR
            Write-Host ""
            Write-Host ":: - Veeam SOBR Repository Configured - ::" -ForegroundColor Green -BackgroundColor Black
            $EndTimeSR = Get-Date
            $durationSR = [math]::Round((New-TimeSpan -Start $StartTimeSR -End $EndTimeSR).TotalMinutes,2)
            Write-Host "Execution Time" $durationLR -ForegroundColor Green -BackgroundColor Black
            Write-Host ""
        }  

    if(!$NoDefaultJobs)
        {
            $StartTimeTG = Get-Date
            Create-vSphereTags
            Write-Host ""
            Write-Host ":: - vSphere Tags Created - ::" -ForegroundColor Green -BackgroundColor Black
            $EndTimeTG = Get-Date
            $durationTG = [math]::Round((New-TimeSpan -Start $StartTimeTG -End $EndTimeTG).TotalMinutes,2)
            Write-Host "Execution Time" $durationTG -ForegroundColor Green -BackgroundColor Black
            Write-Host ""
            
            $StartTimeJB = Get-Date
            Create-VBRJobs
            Write-Host ""
            Write-Host ":: - Backup Jobs Configured - ::" -ForegroundColor Green -BackgroundColor Black
            $EndTimeJB = Get-Date
            $durationJB = [math]::Round((New-TimeSpan -Start $StartTimeJB -End $EndTimeJB).TotalMinutes,2)
            Write-Host "Execution Time" $durationJB -ForegroundColor Green -BackgroundColor Black
            Write-Host ""
        }
}

if ($ClearVBRConfig){
    #Run the code for VBR Clean

    $StartTimeCL = Get-Date
    ClearVBRConfig
    Write-Host ""
    Write-Host ":: - Clearing Backup & Replication Server Configuration - ::" -ForegroundColor Green -BackgroundColor Black
    $EndTimeCL = Get-Date
    $durationCL = [math]::Round((New-TimeSpan -Start $StartTimeCL -End $EndTimeCL).TotalMinutes,2)
    Write-Host "Execution Time" $durationCL -ForegroundColor Green -BackgroundColor Black
    Write-Host ""
}

$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

$host.ui.RawUI.WindowTitle = "AUTOMATION AND ORCHESTRATION COMPLETE"
Write-Host "Total Execution Time" $duration -ForegroundColor Green -BackgroundColor Black
Write-Host
