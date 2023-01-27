### Firewall rules module - variables definition file ###
variable "user_id" {
    description = "unique ID of the user"
    type = string
}


variable "name" {
    description = "firewall rule name"
    type = string
}

variable "network" {
    description = "VPC name"
    type = string
}

variable "protocol" {
    description = "network protocol type"
    type = string
}

variable "ports" {
    description = "network ports"
    type = list
}

variable "source_ranges" {
    description = "source IP ranges"
    type = list
}