### Network peer module - creates VPC peering ####

resource "google_compute_network_peering" "vbg" {

  name         = var.name
  network      = var.network
  peer_network = var.peer_network
}
