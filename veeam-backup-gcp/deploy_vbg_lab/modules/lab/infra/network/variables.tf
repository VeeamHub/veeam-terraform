### Network module - variables definition file ###

variable "user_id" {
    description = "unique ID of the user"
    type = string
}

variable "vpc_name_prefix" {
    description = "prefix for the name of the VPC - full name made of prefix + user_id"
    type = string
}

variable "vpc_subnet_name_prefix" {
    description = "prefix for the name of the VPC subnet - full name made of prefix + user_id"
    type = string
}

variable "ip_cidr_range" {
    description = "IP range of the VPC subnet"
    type = string
}

variable "private_ip_google_access" {
    description = "access to Google APIs and services from private IPs subnets "
    type = bool
}

variable "address" {
    description = "private IP address in the subnet"
    type = string    
}

variable "gcp_region" {
    description = "GCP region"
    type = string
}

