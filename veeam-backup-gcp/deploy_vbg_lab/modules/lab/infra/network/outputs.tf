output "vpc" {
    value = google_compute_network.vpc
}

output "subnet" {
    value = google_compute_subnetwork.subnet
}

output "private_ip" { 
    value = google_compute_address.private_ip
}

output "public_ip" {
    value = google_compute_address.public_ip
}