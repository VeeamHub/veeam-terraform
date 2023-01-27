###  Module deploys a full VBG lab for each user defined by user_id ###

### NETWORK ###
# Create VPCs, subnets and private IP addresses in the subnets 
module "network_infra" {
  source = "./infra/network"

  for_each = var.networks

  user_id = var.user_id
  vpc_name_prefix = each.value.vpc_name_prefix
  vpc_subnet_name_prefix = each.value.vpc_subnet_name_prefix
  ip_cidr_range = each.value.ip_cidr_range
  private_ip_google_access = each.value.private_ip_google_access
  address = each.value.private_ip_address
  gcp_region = var.gcp_region
}

# Create firewall rules
module "firewall_rules" {
  source = "./infra/firewall"

  for_each = var.firewall_rules

  user_id = var.user_id
  name = each.value.name
  network = module.network_infra[each.value.vpc_type].vpc.name 
  protocol = each.value.protocol
  ports = each.value.ports
  source_ranges = each.value.source_ranges
}

# Create network peering between VPCs 
module "network_peer" { 
  source = "./infra/network_peer"

  for_each = var.peer_networks

  name         = "peer-${each.value.src_vpc_type}-to-${each.value.dst_vpc_type}-${var.user_id}"
  network      = module.network_infra["${each.value.src_vpc_type}"].vpc.id
  peer_network = module.network_infra["${each.value.dst_vpc_type}"].vpc.id
  
}

### STORAGE ###
module "repo_bucket" { 
  source = "./infra/storage"

  for_each = var.storage_bucket
  
  user_id = var.user_id
  name_prefix = each.value.name_prefix
  location = each.value.location
  storage_class = each.value.storage_class
  force_destroy = each.value.force_destroy
  public_access_prevention = each.value.public_access_prevention
}

### WEB VM instance ###
module "web_app" { 
  source = "./web_app"

  count = var.machine_type_web_app != "" ? 1 : 0
 
  user_id = var.user_id
  machine_type = var.machine_type_web_app
  boot_disk_image = var.boot_disk_image_web_app
  network = module.network_infra["web"].vpc.name
  subnetwork = module.network_infra["web"].subnet.name
  network_ip = module.network_infra["web"].private_ip[0].address
  nat_ip = module.network_infra["web"].public_ip.address
}

#### Veeam Backup for GCP instance #####
module "vbg" { 
  source = "./vbg"
 
  count = var.machine_type_vbg != "" ? 1 : 0

  user_id = var.user_id
  machine_type = var.machine_type_vbg
  boot_disk_image = var.boot_disk_image_vbg
  network = module.network_infra["backup"].vpc.name
  subnetwork = module.network_infra["backup"].subnet.name
  network_ip = module.network_infra["backup"].private_ip[0].address
  nat_ip = module.network_infra["backup"].public_ip.address
  # data disk
  type = var.data_disk_type
  size = var.data_disk_size
}
