### Network module - creates VPC, subnet and reserves private and public IP address ###

resource "google_compute_network" "vpc" {
  name                    = "${var.vpc_name_prefix}-${var.user_id}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.vpc_subnet_name_prefix}-${var.user_id}"
  ip_cidr_range = "${var.ip_cidr_range}"
  network       = google_compute_network.vpc.id
  private_ip_google_access = var.private_ip_google_access
}

resource "google_compute_address" "private_ip" {
  count = var.address != "" ? 1 : 0

  name = "private-ip-${var.vpc_subnet_name_prefix}-${var.user_id}"  
  subnetwork = google_compute_subnetwork.subnet.id
  address_type = "INTERNAL"
  address = "${var.address}"
}

resource "google_compute_address" "public_ip" {
  name = "public-ip-${var.vpc_subnet_name_prefix}-${var.user_id}"  
  region = "${var.gcp_region}"
  address_type = "EXTERNAL"
}