### VBG instance module - creates VBG compute instance and service account  ###

### VBG data disk ### 
resource "google_compute_disk" "vbg_data" {
  name  = "vbg-vm-${var.user_id}-data"
  type  = var.type
  size = var.size
}

### VBG service account ###
resource "google_service_account" "vbg" {
  account_id   = "vbg-${var.user_id}-sa"
  display_name = "Service Account VBG ${var.user_id}"
}


### VBG instance ###
resource "google_compute_instance" "vbg" {
  name         = "vbg-vm-${var.user_id}"
  machine_type = var.machine_type

  metadata = {
    ATTACHED_DISKS = "vbg-vm-${var.user_id}-data"
    veeam-deployment-name = "vbg-vm-${var.user_id}"
  }

  metadata_startup_script = "bash /usr/bin/instance-startup-script.sh"

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
    }
    device_name = "vbg-vm-${var.user_id}-boot"
  }

  attached_disk {
    source = google_compute_disk.vbg_data.self_link
    device_name = "vbg-vm-${var.user_id}-data"
  }

  network_interface {
    network = var.network
    subnetwork = var.subnetwork
    network_ip = var.network_ip
    access_config {
      nat_ip = var.nat_ip
    }
  }

  service_account {
    email  = google_service_account.vbg.email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot = true
  }
}
