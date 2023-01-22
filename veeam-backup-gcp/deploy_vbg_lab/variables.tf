variable "gcp_region" {
    description = "GCP region"
    type = string
    default = "europe-west4"
}

variable "gcp_zone" {
    description = "GCP zone"
    type = string
    default = "europe-west4-b"
}

variable "gcp_project" {
    description = "project name where to deploy VBG"
    type = string
    default = "vb-gcp"
}

variable "user_id" {
    description = "unique ID of the user"
    type = map(any)
}


# Networking infra
variable "networks" {
  description = "map of VPCs"
  type = map(any)
}

variable "firewall_rules" {
  description = "map of firewall rules for backup and web networks"
  type = map(any)
}

variable "peer_networks" {
  description = "map of VPC peerings"
  type = map(any)
}    

# Cloud storage repositories
variable "storage_bucket" {
  description = "map for repo storage bucket"
  type = map(any)
}

# Web app instance specs
variable "machine_type_web_app" {
    description = "machine type for web app VM instance" 
    type = string      
}

variable "boot_disk_image_web_app" {
    description = "boot disk image for web app VM instance"
    type = string      
}

# VBG specs
variable "data_disk_type" {
    description = "VBG data disk type"
    type = string    
}

variable "data_disk_size" {
    description = "VBG data disk size in GB"
    type = number    
}

variable "machine_type_vbg" {
    description = "machine type for VBG VM instance" 
    type = string      
}

variable "boot_disk_image_vbg" {
    description = "boot disk image for VBG VM instance"
    type = string      
}
