
variable "subscription_id" { 
    description = "Azure subscription ID" 
    type = string
    default = "ABCDEFGH" 
}

variable "user_id" { 
    description = "unique string to identify deployed resources" 
    type = string
    default = "VeeamHub001" # used in storage account name also, keep it under 16 chars
}

variable "az_location" {
    description = "Azure location"
    type = string
    default = "West US 3"
}

variable "tag_owner" { 
    description = "tag used for all created resources" 
    type = string
    default = "someone@your.org" 
}

variable "tag_environment" { 
    description = "tag used for all created resources" 
    type = string
    default = "dev" 
}

# VBAZ image variables
### to list available images, run the below az cli command
### az vm image list --offer azure_backup_free --all
variable "vbaz_offer" {
    description = "image offer"
    type = string
    default = "azure_backup_free"
}

variable "vbaz_sku" {
    description = "image sku"
    type = string
    default = "veeambackupazure_free_v6_0"
}

variable "vbaz_version" {
    description = "image version"
    type = string
    default = "6.0.234"
}

# network variables
variable "backup_address_space" {
    description = "address space for backup vnet"
    type = list
    default = ["10.10.0.0/16"]
}

variable "backup_subnet" {
    description = "IP network for backup subnet"
    type = list
    default = ["10.10.0.0/24"]
}

variable "nsg_source_addresses" {
    description = "list of extenral IP addresses allowed to connect to VBAZ"
    type = list  
    default = ["8.8.8.8"]
}

# VBAZ VM variables
variable "internal_ip" {
    description = "VBAZ internal IP address"
    type = string
    default = "10.10.0.250"
}

variable "vm_size" {
    description = "VBAZ VM size"
    type = string
    default = "Standard_B2s"
}

variable "vbaz_disk_type" {
    description = "type of disk for VBAZ storage"
    type = string
    default = "Standard_LRS"
}

variable "admin_username" {
    description = "username for VBAZ admin"
    type = string
    default = "vbazadmin"
}

### IMPORTANT - DO NOT KEEP PASSWORDS HERE
### Use Vault or environment variables 
### or other methods to securely store passwords
variable "admin_password" { 
    description = "password for VBAZ admin user"
    type = string
    default = "ThisIsWrong!12345"
}

# Storage account variables
variable "stg_public_ip_list" {
    description = "list of public IP addresses allowed to connect to storage account during deployment"
    type = list  
    default = ["8.8.8.8"]
}

variable "stg_account_prefix" {
    description = "storage account prefix"
    type = string
    default = "stgrepo"
}

variable "stg_account_tier" {
    description = "storage account tier"
    type = string
    default = "Standard"
}

variable "stg_account_replication_type" {
    description = "storage account replication type"
    type = string
    default = "LRS"
}

