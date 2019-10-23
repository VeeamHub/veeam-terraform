# DEPLOY VEEAM SDDC TOOLKIT

![alt text](http://anthonyspiteri.net/wp-content/uploads/2019/03/Veeam_SDDC_Deployment_Toolkit_2.png "Overall Solution")

## Automated Deployment of Veeam on VMware with Veeam Linux Repo connected by VeeamPN

This set of PowerShell and Terraform scripts will deploy a fully configured Veeam environment onto a VMware vSphere platform. VMware Cloud on AWS can also be used as showcased
at VMworld 2018 by Anthony Spiteri and Michael Cade (https://videos.vmworld.com/searchsite/2018/videoplayer/19282)

This is an end to end solution and assumes everything to be in place by way of the requirements and pre-reqs

There are four modules

- Deploy and Install Veeam Backup & Replication 9.5 Update 4 components on a new VM from Template using Chef and Terraform
- Deploy and Configure AWS VPC for Veeam Linux Repo and Veeam PN Sitegateway using Terraform
- Deploy and Configure local Veeam Linux Repo
- Configure Veeam Backup & Replication 9.5 Update 4 using PowerShell and PowerCLI

### Requirements

- [Terraform 0.11.8+](https://www.terraform.io/downloads.html)
- Windows Template with Windows Remote Management enabled and configured for Terraform and up to date VMware Tools
- Backup & Replication 9.5 Update 4 Console Installed on remote execution machine
- vSphere Details and Credentials (Or VMware Cloud on AWS Credentials)
- Current Veeam License File converted to BASE64 and saved in terraform.tfvars file as license_base64_encoded variable in \veeam_standalone_full directory (Example 30 Day NFR Key embedded)

### Optional Requirements

- Linux Template for Local Linux Deployment
- Veeam PN Deployed and Configured with Hub (see https://anthonyspiteri.net/)
- Veeam PN Site Gateway XML Configuration File for AWS VPC Network (see https://anthonyspiteri.net/)
- AWS Credentials and pre generated key file for AWS Linux AMIs
- Amazon S3 Bucket Created
- Veeam Cloud Connect Provider Credentials
- Current Veeam License File converted to BASE64 and saved as license.json in \veeam_standalone_full directory

### Getting Started

```text
PARAMETER Runall - Runs all the functions with all features including Remote AWS Linux Repo, Veeam PN and SOBR with Capacity Tier
PARAMETER RunVBRConfigure - Runs all the functions to configure VBR Server
PARAMETER RunVBRDeployOnly - Runs the VBR deployment Terraform Module
PARAMETER RunAWSDeploy - Runs the AWS VeeamPN and Veeam Repo deployment Terraform Module
PARAMETER LocalLinuxRepoDeploy - When used in combination with Runall or RunVBRConfigure will Deploy local Linux Repo using Terraform Module
PARAMETER CloudConnectOnly - Used on it's own to configure a Cloud Connect Provider
PARAMETER CloudConnectNEA - When used with RunAll or RunVBRConfigure will deploy and configure the Cloud Connect Network Extension Appliance
PARAMETER NoCloudConnect - When used with RunAll or RunVBRConfigure or CloudConnectOnly will not configure the Cloud Connect component
PARAMETER NoLinuxRepo - When used with RunAll or RunVBRConfigure will not add and configure the Linux Repository
PARAMETER NoDefaultJobs - Will not configure Tags or Default Jobs when run with RunVBRConfigure
PARAMETER ConfigureSOBR - Will configure a SOBR with two extents when run with RunVBRConfigure with an AWS S3 Capacity Teir
PARAMETER NoCapacityTier - Will not configure an AWS S3 Based Object Storage Repo when used with ConfigureSOBR
PARAMETER ClearVBRConfig - Will clear all previously configured settings and return Veeam Backup & Replication Server to default install

EXAMPLE - PS C:\>deploy_veeam_sddc_release.ps1 -Runall
EXAMPLE - PS C:\>deploy_veeam_sddc_release.ps1 -Runall -LocalLinuxRepoDeploy
EXAMPLE - PS C:\>deploy_veeam_sddc_release.ps1 -RunVBRConfigure -NoLinuxRepo
EXAMPLE - PS C:\>deploy_veeam_sddc_release.ps1 -ClearVBRConfig
EXAMPLE - PS C:\>deploy_veeam_sddc_release.ps1 -RunVBRConfigure -ConfigureSOBR -NoCapacityTier
```

The Terraform templates included in this repository requires Terraform to be available locally on the machine running the templates.  Before you begin, please verify that you have the following information:

1. Download [Terraform](https://www.terraform.io/downloads.html) (minimum tested version 0.11.8) binary to your workstation.
2. Gather the VMware credentials required to communicate to vCenter
3. Save a copy of the file `terraform.tfvars.example` as `terraform.tfvars`
4. Update the variable values in the newly created `terraform.tfvars` file.

### WinRM Config for Template

```powershell
winrm quickconfig -q
winrm set winrm/config/service ‘@{AllowUnencrypted=“true”}’
winrm set winrm/config/service/auth ‘@{Basic=“true”}’
Start-Service WinRM
Set-Service WinRM -StartupType Automatic
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled false”
```

### config.json Breakdown

All of the variables are configured in the config.json file. Nothing is required to be changed in the main depply script.

```json
{
        "Default": {
                "Path":"C:\\Users\\anthonyspiteri\\Documents\\automation\\deploy_veeam_sddc_toolkit",
                "ChefPath":"C:\\Users\\anthonyspiteri\\Documents\\automation\\deploy_veeam_sddc_toolkit\\veeam_standalone_full\\",
                "TFOutputVBR":"C:\\Users\\anthonyspiteri\\Documents\\automation\\deploy_veeam_sddc_toolkit\\vbr_ip.json",
                "AWSDeployPath":"C:\\Users\\anthonyspiteri\\Documents\\automation\\deploy_veeam_sddc_toolkit\\aws_create_veeamrepo_veeampn\\",
                "LinuxRepoBuildPath":"C:\\Users\\anthonyspiteri\\Documents\\automation\\deploy_veeam_sddc_toolkit\\veeam_linux_repo\\",
                "LinuxRepoIP":"C:\\Users\\anthonyspiteri\\Documents\\automation\\deploy_veeam_sddc_toolkit\\ip.json"
        },
        "SOBRRepo": {
                "AWSAccesskey":"",
                "AWSSecretkey":"",
                "S3Folder": "ct03new",
                "S3Bucket":"veeam-ps-ct03",
                "ObjectStorageRepoName":"AWS-CT-03",
                "ObjectStorageRepoLimit":"1024000",
                "RepoName":"SOBR-01",
                "RepoExtent1":"",
                "RepoPath1":"",
                "RestoreWindow":"30"
        },
        "LinuxRepo": {
                "VBRServer":"localhost",
                "IpAddress":"",
                "Username": "centos",
                "Key":"C:\\Users\\anthonyspiteri\\Documents\\automation\\deploy_veeam_sddc_toolkit\\aws_create_veeamrepo_veeampn\\KEY-VEEAM-03.pem",
                "RepoName":"AWS-US-1-REPO-01",
                "RepoFolder":"/home/repo01",
                "LocalRepoName":"LINUX-REPO-01",
                "LocalUsername":"root",
                "LocalPassword":"Veeam1!"
        },
        "VCCProvider": {
                "VBRServer":"VBRSERVER",
                "vCenterServer":"VCENTER",
                "vCenterDVS":"LAB-DVS-00",
                "vCenterPortGroup":"VM-Management",
                "vCenterDatastore":"HDD-1",
                "vCenterResPool":"SDDC",
                "ESXiHost":"ESXIHOST",
                "CCUserName":"VCC_USERNAME",
                "CCPassword":"xxxxxxxx",
                "CCServerAddress":"VCCADDRESS",
                "CCRepoName":"VCC_USERNAME",
        },
        "VBRCredentials": {
                "VBRServer":"192.168.1.231",
                "Username":"USERNAME",
                "Password":"PASSWORD"
        },
        "VMCCredentials": {
                "vCenter":"lab-vc-01.sliema.lab",
                "Username":"USERNAME",
                "Password":"PASSWORD"
        },
        "VBRJobDetails": {
                "DefaultRepo1":"Default Backup Repository",
                "Job1":"CCR-01",
                "Job2":"CCB-02",
                "Job3":"CCB-03",
                "TagCatagory1":"Backup",
                "TagCatagory2":"Replication",
                "Tag1":"TIER-1",
                "Tag2":"TIER-2",
                "Tag3":"TIER-3",
                "FullDay":"Friday",
                "Time1":"22:00",
                "Time2":"02:00",
                "RestorePoints1":"7",
                "RestorePoints2":"30"
        }
}
```
