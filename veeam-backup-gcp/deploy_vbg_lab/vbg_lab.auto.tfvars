gcp_region = "europe-west4"
gcp_zone = "europe-west4-b"
gcp_project = "vb-gcp"

user_id = {
    lab1 = {
        id = "veeam001"     # unique ID for the user; it is used to create unique names for resources
    },
    # lab2 = {
    #     id = "veeam002"
    # }
    # lab3 = {
    #     id = "veeam003"
    # }
}

# names of network map elements given here (backup, web) are referenced by other resources (firewall rules, peer)
# you can add more VPCs by adding new elements in the map
# at least VBG VPC is needed
networks = {
    backup = {                                          
        vpc_name_prefix = "vpc-backup"                  # prefix used to create vpc name (prefix + user_id)      
        vpc_subnet_name_prefix = "subnet-backup"        # prefix used to create subnet name (prefix + user_id)      
        ip_cidr_range = "10.100.0.0/24"                 # subnet CIDR    
        private_ip_google_access = true                 # access to Google API and services using private IPs
        private_ip_address = "10.100.0.10"              # reserves private IP address for VBG; public IP is reserved by default
    },
    web = {
        vpc_name_prefix = "vpc-web-app"
        vpc_subnet_name_prefix = "subnet-web-app"
        ip_cidr_range = "10.1.0.0/24"
        private_ip_google_access = false
        private_ip_address = "10.1.0.10"
    }
}

# you can add more firewall rules here
# each firewall rule is mapped back to the VPC by vpc_type variable
# vpc_type matches the name of the networks map elements e.g backup or web
firewall_rules = {
    allow_https_backup = {
        vpc_type = "backup"                  # vpc_type matches the name of the networks map elements e.g backup or web
        name = "allow-https-backup"
        protocol = "tcp" 
        ports    = ["443"]
        source_ranges = ["0.0.0.0/0"]
    },
    allow_ssh_backup = {
        vpc_type = "backup"                  # vpc_type matches the name of the networks map elements e.g backup or web
        name = "allow-ssh-backup"
        protocol = "tcp" 
        ports    = ["22"]
        source_ranges = ["0.0.0.0/0"]
    },
    allow_https_web_app = {
        vpc_type = "web"                    # vpc_type matches the name of the networks map elements e.g backup or web
        name = "allow-https-web-app"
        protocol = "tcp" 
        ports    = ["443"]
        source_ranges = ["0.0.0.0/0"]
    }
}


# peer_networks = {}    # does not peer any VPCs 
peer_networks = {
    backup_to_web = {
        src_vpc_type = "backup"     # value matches the name of the networks map elements e.g backup or web
        dst_vpc_type = "web"        # value matches the name of the networks map elements e.g backup or web
    },
    web_to_backup = {
        src_vpc_type = "web"
        dst_vpc_type = "backup"
    }
}


# storage_bucket = {} # does not create any Google cloud buckets
storage_bucket = {
    repo_prod = {
        name_prefix = "backup-repo-prod"        # value matches the name of the networks map elements e.g backup or web
        location = "EUROPE-WEST4"               # bucket region 
        storage_class = "STANDARD"              # STANDARD or ACHIVE 
        force_destroy = true                    # deletes the bucket and its content on resource deletion - good for lab, not prod
        public_access_prevention = "enforced"   # denies public access to the bucker - enforced or inherited
    },
    # repo_dev = {
    #     name_prefix = "backup-repo-dev"           
    #     location = "EUROPE-WEST4"
    #     storage_class = "STANDARD"              
    #     force_destroy = true                    
    #     public_access_prevention = "enforced"
    # }
}

### web app VM instance ###
# machine_type_web_app = ""     # will not deploy web VM instance
machine_type_web_app = "e2-micro"
boot_disk_image_web_app = "projects/bitnami-launchpad/global/images/bitnami-wordpress-6-0-1-2-r02-linux-debian-11-x86-64-nami"

### VBG VM instance ###
# machine_type_vbg = ""     # just in case - will not deploy VBG VM instance 
machine_type_vbg = "e2-standard-2"
boot_disk_image_vbg = "projects/veeam-marketplace-public/global/images/veeam-backup-gcp-30-ubuntu2004-20221104"
data_disk_type = "pd-ssd"
data_disk_size = 20

