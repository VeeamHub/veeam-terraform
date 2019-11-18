/*
Output Variables
*/
output "vbr_host" {
  value = "${vsphere_virtual_machine.vbr_server.default_ip_address}"
}

output "proxy_host" {
  value = "${vsphere_virtual_machine.proxy.*.default_ip_address}"
}
