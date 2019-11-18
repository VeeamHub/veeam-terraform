variable "vsphere_user" {
  description = "vSphere user name"
}

variable "vsphere_password" {
  description = "vSphere password"
}

variable "vsphere_vcenter" {
  description = "vCenter server FQDN or IP"
}

variable "vsphere_unverified_ssl" {
  description = "Is the vCenter using a self signed certificate (true/false)"
}

# VM specifications

variable "vsphere_datacenter" {
  description = "In which datacenter the VM will be deployed"
}

variable "vsphere_vm_name" {
  description = "What is the name of the VM"
}

variable "vsphere_vm_template" {
  description = "Where is the VM template located"
}

variable "vsphere_vm_folder" {
  description = "In which folder the VM will be store"
}

variable "vsphere_cluster" {
  description = "In which cluster the VM will be deployed"
}

variable "vsphere_vcpu_number" {
  description = "How many vCPU will be assigned to the VM (default: 1)"
  default     = "1"
}

variable "vsphere_memory_size" {
  description = "How much RAM will be assigned to the VM (default: 1024)"
  default     = "1024"
}

variable "vsphere_datastore" {
  description = "What is the name of the VM datastore"
}

variable "vsphere_port_group" {
  description = "In which port group the VM NIC will be configured (default: VM Network)"
  default     = "VM Network"
}

variable "vsphere_ipv4_address" {
  description = "What is the IPv4 address of the VM"
}

variable "vsphere_ipv4_netmask" {
  description = "What is the IPv4 netmask of the VM (default: 24)"
  default     = "24"
}

variable "vsphere_ipv4_gateway" {
  description = "What is the IPv4 gateway of the VM"
}

variable "vsphere_dns_servers" {
  description = "What are the DNS servers of the VM (default: 8.8.8.8,5.5.5.5)"
  default     = "8.8.8.8,5.5.5.5"
}

variable "vsphere_domain" {
  description = "What is the domain of the VM"
}

variable "vsphere_time_zone" {
  description = "What is the timezone of the VM (default: UTC)"
  default     = "UTC"
}