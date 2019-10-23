# VMware vCloud Director NAT Ressource Definition
resource "vcd_dnat" "ssh" {

  edge_gateway    = "${var.vcd_edge}"
  external_ip     = "${var.vcd_external_ip}"
  port            = 22
  internal_ip     = "${var.vcd_vm_1}"
  translated_port = 22
}
resource "vcd_dnat" "http" {

  edge_gateway    = "${var.vcd_edge}"
  external_ip     = "${var.vcd_external_ip}"
  port            = 80
  internal_ip     = "${var.vcd_vm_1}"
  translated_port = 80
}

resource "vcd_dnat" "https" {

  edge_gateway    = "${var.vcd_edge}"
  external_ip     = "${var.vcd_external_ip}"
  port            = 443
  internal_ip     = "${var.vcd_vm_1}"
  translated_port = 443
}

resource "vcd_snat" "outbound" {
  edge_gateway   = "${var.vcd_edge}"
  external_ip    = "${var.vcd_external_ip}"
  internal_ip    = "${var.vcd_vorg_network}"
}