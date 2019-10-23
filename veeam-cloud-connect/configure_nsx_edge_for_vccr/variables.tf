# VMware vCloud Director Provider Variables (Blank)
variable "vcd_user" {
    description = "vCD Tenant User"
}
variable "vcd_pass" {
   description = "vCD Tenant Password"
}
variable "vcd_org" {
   description = "vCD Tenant Org"
}
variable "vcd_url" {
   description = "vCD Tenant URL"
}
variable "vcd_vdc" {
   description = "vCD Tenant VDC"
}
variable "vcd_edge" {
    description = "vCD Tenant Edge Gateway"
}
variable "vcd_external_ip" {
    description = "vCD External Edge IP"
}
variable "vcd_vm_1" {
    description = "Virtual Machine IP for NAT and FW Rules"
}
variable "vcd_vorg_network" {
    description = "vCD vOrg Network Subnet and Mask"
}
variable "vcd_max_retry_timeout" {
   description = "Retry Timeout"
   default = "240"
}