subscription_id = "ABBCDEFG" # update with your subscription ID

tag_owner = "someone@your.org"
tag_environment = "devprodall"

# change to deploy a different image of VBAZ
vbaz_offer = "azure_backup_free"
vbaz_sku = "veeambackupazure_free_v6_0"
vbaz_version = "6.0.234"

# variables 
user_id = "VeeamHub001"
az_location = "West US 3"

backup_address_space = ["10.10.0.0/16"]
backup_subnet = ["10.10.0.0/24"]
nsg_source_addresses = ["8.8.8.8"] # change to list all public IPs from where you access VBAZ 
internal_ip = "10.10.0.250"
vm_size = "Standard_B2s"
vbaz_disk_type = "Standard_LRS"
admin_username = "vbazadmin"
# IMPORTANT - DO NOT KEEP PASSWORDS HERE
# Use Vault or environment variables 
# or other methods to securely store passwords
admin_password = "ThisIsWrong!12345"

stg_public_ip_list = ["8.8.8.8"] # change to list all public IPs from where Terraform is executed - public access to storage account should be removed
stg_account_prefix = "stgrepo"
stg_account_tier = "Standard"
stg_account_replication_type = "LRS"

