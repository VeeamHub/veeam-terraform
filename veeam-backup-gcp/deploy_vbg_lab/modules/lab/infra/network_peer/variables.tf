### Network peer module - variables definition file ###

variable "name" {
    description = "name of nework peer"
    type = string
}

variable "network" {
    description = "source VPC ID"
    type = string
}

variable "peer_network" {
    description = "destination VPC ID"
    type = string
}
