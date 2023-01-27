### Firewall rules module - creates firewall rules ###

resource "google_compute_firewall" "rules" {
  name    = "${var.name}-${var.user_id}"
  network = "${var.network}"

  allow {
    protocol = "${var.protocol}"
    ports    = var.ports
  }

  source_ranges = var.source_ranges
}