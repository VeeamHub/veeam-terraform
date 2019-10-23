<#
.SYNOPSIS
configure_vCD_VCCR_NSX_EDGE.ps1
.DESCRIPTION
#>

function Run-Terraform 
    {
        $host.ui.RawUI.WindowTitle = "Configuring NSX Edge for VCCR Failover"
        & .\terraform.exe init
        & .\terraform.exe init -upgrade
        & .\terraform.exe apply -auto-approve
    }

Run-Terraform
