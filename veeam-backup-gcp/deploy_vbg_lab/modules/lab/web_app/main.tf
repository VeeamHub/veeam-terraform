### Web app instance module - creates web app (wordpress) compute instance   ###

resource "google_compute_instance" "web" {
  name         = "web-vm-${var.user_id}"
  machine_type = var.machine_type

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
    }
  }

  network_interface {
    network = var.network
    subnetwork = var.subnetwork
    network_ip = var.network_ip
    access_config {
      nat_ip = var.nat_ip
    }
  }
}

