# Windows Host preparation for Bootstrapping
#
# maintainer:: Exosphere Data, LLC
# maintainer_email:: chef@exospheredata.com
#
# Copyright:: 2018, Exosphere Data, LLC, All Rights Reserved.
#


Write-Host "Prepare the host for Chef Bootstrapping"
try {
  if (Test-Path -Path C:\tmp\chef) {
    Write-Host "`tRemove Previous Temporary Chef upload location"
    Remove-Item -Recurse -Confirm:$False C:\tmp\chef
  }

  if (Test-Path -Path C:\tmp\chef_cookbooks) {
    Write-Host "`tRemove Previous Temporary Chef Cookbook location"
    Remove-Item -Recurse -Confirm:$False C:\tmp\chef_cookbooks
  }
  Write-Host "`tSetup the repositories"
  New-Item -Type Directory C:\tmp\chef\data_bags\veeam | Out-Null
  Write-Host "`tSetup the cookbook repositories"
  New-Item -Type Directory C:\tmp\chef_cookbooks | Out-Null
}
catch {
  throw $_.Exception.Message
  exit 1
}
