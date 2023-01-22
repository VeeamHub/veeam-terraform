### Storage bucket module - variables definition file ###
variable "user_id" {
    description = "unique ID of the user"
    type = string
}

variable "name_prefix" {
    description = "storage bucket name prefix - full name is concatantion of prefix and user_id"
    type = string
}

variable "location" {
    description = "storage bucket location"
    type = string
}

variable "storage_class" {
    description = "storage bucket class"
    type = string
}

variable "force_destroy" {
    description = "enforce bucket destroy"
    type = bool
}

variable "public_access_prevention" {
    description = "public access to the bucket - enforced or inherited"
    type = string
}


