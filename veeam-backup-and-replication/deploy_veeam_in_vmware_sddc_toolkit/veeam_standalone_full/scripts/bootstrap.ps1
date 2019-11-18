# Windows Bootstrap with Local Chef Client
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2018, Exosphere Data, LLC, All Rights Reserved.
#


Write-Host "Package up Chef Cookbooks based on Berksfile"
try {
  Set-Location -Path C:\tmp\chef_cookbooks
  if (Test-Path -Path C:\tmp\cookbooks.tar.gz) {
    Write-Host "`tRemove Previous Cookbook Archive file"
    Remove-Item -Confirm:$False C:\tmp\cookbooks.tar.gz
  }

  $berks_installed = [boolean](C:\opscode\chef\embedded\bin\gem.bat list berkshelf | Select-String berkshelf)
  if (!$berks_installed) {
    Write-Host "`tInstall Berkshelf Gem"
    Invoke-Expression -Command "C:\opscode\chef\embedded\bin\gem.bat install berkshelf --no-ri --no-rdoc" | Out-Null
    if($LASTEXITCODE -ne 0) { throw "Failed to install Berkshelf Gem"}
  }

  Write-Host "`tCreate Berks Package based on Berksfile"
  $output = Invoke-Expression -Command "C:\opscode\chef\embedded\bin\berks.bat package --berksfile=Berksfile"
  if($LASTEXITCODE -ne 0) { throw "Failed to package cookbook archive"}
  $cookbook_archive = $output.split("/")[-1]

  Write-Host "`tRename unique cookbook archive name to standard file name"
  Move-Item -Path $cookbook_archive -Destination C:\tmp\cookbooks.tar.gz
} catch {
  throw $_.Exception.message
  exit 1
} finally {
  Set-Location $PSScriptRoot
}

Write-Host "Configure files for bootstrapping"
try {
  if (Test-Path -Path C:\chef) {
    Write-Host "`tRemove existing chef files and configurations"
    Remove-Item -Recurse -Confirm:$False C:\chef\
  }

  Write-Host "`tSetup the repositories"
  New-Item -Type Directory C:\chef\cookbooks | Out-Null

  Move-Item -Path C:\tmp\chef\* -Destination C:\chef\
} catch {
  throw $_.Exception.message
  exit 1
}
try {
  Write-Host "Start the CHEF Client and configuration bootstrap"
  Invoke-Expression -Command "C:\opscode\chef\embedded\bin\chef-solo.bat --recipe-url /tmp/cookbooks.tar.gz -c C:/chef/solo.rb -j C:/chef/dna.json -l info"
  if($LASTEXITCODE -ne 0) {
    # This will allow the logs to finish writing to the screen before we fail out.
    Start-Sleep -s 5
    throw "Chef Boostrap Failed"
  }
} catch {
  throw $_.Exception.message
  exit 1
}
