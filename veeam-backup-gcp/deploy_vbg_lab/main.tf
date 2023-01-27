############
### LAB  ###
############
provider "google" {
  region      = "${var.gcp_region}"
  zone        = "${var.gcp_zone}"
  project     = "${var.gcp_project}"
}

module "vbg_lab" {
  source = "./modules/lab"

  for_each = var.user_id

  user_id = each.value.id
  gcp_region = var.gcp_region
  # network
  networks = var.networks
  firewall_rules = var.firewall_rules
  peer_networks = var.peer_networks
  # storage
  storage_bucket = var.storage_bucket
  # web app
  machine_type_web_app = var.machine_type_web_app
  boot_disk_image_web_app = var.boot_disk_image_web_app
  # VBG
  data_disk_type = var.data_disk_type
  data_disk_size = var.data_disk_size
  machine_type_vbg = var.machine_type_vbg
  boot_disk_image_vbg = var.boot_disk_image_vbg
}

### modularize to deploy only VBG without WEB, or without storage
### modularize public IP 
