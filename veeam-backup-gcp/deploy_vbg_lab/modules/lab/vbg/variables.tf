### VBG instance module - variables definition file ###

variable "user_id" {
    description = "unique ID of the user"
    type = string
}

variable "type" {
    description = "VBG data disk type"
    type = string    
}

variable "size" {
    description = "VBG data disk size in GB"
    type = number    
}

variable "machine_type" {
    description = "type of VM instance"
    type = string    
}

variable "boot_disk_image" {
    description = "the image from which to initialize boot disk"
    type = string    
}

variable "network" {
    description = "VPC to use for the VM instance "
    type = string    
}

variable "subnetwork" {
    description = "subnet to connect VM instance "
    type = string    
}

variable "network_ip" {
    description = "private IP for the VM instance "
    type = string    
}

variable "nat_ip" {
    description = "public IP for the VM instance "
    type = string    
}