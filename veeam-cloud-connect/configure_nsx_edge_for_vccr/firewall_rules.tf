# VMware vCloud Director Firewall  Ressource Definition
resource "vcd_firewall_rules" "fw" {
  edge_gateway   = "${var.vcd_edge}"
  default_action = "drop"

    rule {
    description      = "Allow VCCR Replica ${var.vcd_vm_1} Port 22"
    policy           = "allow"
    protocol         = "tcp"
    destination_port = "22"
    destination_ip   = "${var.vcd_external_ip}"
    source_port      = "any"
    source_ip        = "any"
  }
  
  rule {
    description      = "Allow VCCR Replica ${var.vcd_vm_1} Port 80"
    policy           = "allow"
    protocol         = "tcp"
    destination_port = "80"
    destination_ip   = "${var.vcd_external_ip}"
    source_port      = "any"
    source_ip        = "any"
  }

  rule {
    description      = "Allow VCCR Replica ${var.vcd_vm_1} Port 443"
    policy           = "allow"
    protocol         = "tcp"
    destination_port = "443"
    destination_ip   = "${var.vcd_external_ip}"
    source_port      = "any"
    source_ip        = "any"
  }

  rule {
    description      = "ALLOW ICMP"
    policy           = "allow"
    protocol         = "icmp"
    destination_port = "any"
    destination_ip   = "any"
    source_port      = "any"
    source_ip        = "any"
  }
}