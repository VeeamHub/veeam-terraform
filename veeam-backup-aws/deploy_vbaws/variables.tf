variable "aws_region" {
  description = "AWS region"
  type        = string

  validation {
    condition     = contains(["us-east-1", "us-gov-east-1", "us-gov-west-1", "us-east-2", "us-west-1", "us-west-2", "ca-central-1", "eu-central-1", "eu-west-1", "eu-west-2", "eu-west-3", "eu-north-1", "eu-south-1", "ap-southeast-1", "ap-southeast-2", "ap-southeast-3", "ap-south-1", "ap-northeast-1", "ap-northeast-2", "ap-northeast-3", "ap-east-1", "sa-east-1", "me-south-1", "af-south-1"], var.aws_region)
    error_message = "Unsupported region. Please choose a supported region: us-east-1, us-gov-east-1, us-gov-west-1, us-east-2, us-west-1, us-west-2, ca-central-1, eu-central-1, eu-west-1, eu-west-2, eu-west-3, eu-north-1, eu-south-1, ap-southeast-1, ap-southeast-2, ap-southeast-3, ap-south-1, ap-northeast-1, ap-northeast-2, ap-northeast-3, ap-east-1, sa-east-1, me-south-1, af-south-1"
  }
}

variable "veeam_aws_instance_type" {
  description = "Instance type for the Veeam Backup for AWS appliance"
  type        = string
  default     = "t2.medium"

  validation {
    condition     = contains(["t2.medium", "t2.large", "t2.xlarge", "t2.2xlarge", "t3.medium", "t3.large", "t3.xlarge", "t3.2xlarge", "c5.large", "c5.2xlarge", "c5.4xlarge", "c5.9xlarge"], var.veeam_aws_instance_type)
    error_message = "Unsupported instance type. Please choose a supported instance type from the following list: t2.medium, t2.large, t2.xlarge, t2.2xlarge, t3.medium, t3.large, t3.xlarge, t3.2xlarge, c5.large, c5.2xlarge, c5.4xlarge, c5.9xlarge"
  }
}

variable "elastic_ip" {
  description = "Assign Elastic IP to Veeam Backup for AWS appliance"
  type        = bool
  default     = false
}

variable "vpc_cidr_block_ipv4" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr_block_ipv4" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "veeam_aws_security_group" {
  description = "IP allowed to access the appliance in CIDR notation"
  type        = string
}

variable "veeam_aws_edition" {
  description = "The edition of Veeam Backup for AWS that will be deployed"
  type        = string
  default     = "free"

  validation {
    condition     = contains(["free", "byol", "paid"], var.veeam_aws_edition)
    error_message = "Invalid edition. Supported values are \"free\", \"byol\", \"paid\"."
  }
}

variable "admin_role_id" {
  description = "Unique role ID of the IAM role (AROA*) that will have access to the Veeam S3 bucket"
  type        = string
}

variable "admin_user_id" {
  description = "Unique user ID of the IAM user (AIDA*) that will have access to the Veeam S3 bucket"
  type        = string
}

### DO NOT EDIT THE FOLLOWING ami_map VARIABLES!
### AMI maps for the available editions of Veeam Backup for AWS.

variable "veeam_aws_free_edition_ami_map" {
  description = "AMI map for Veeam Backup for AWS free edition"
  type        = map(any)
  default = {
    "us-east-1"      = "ami-0e3684ce1440e944c"
    "us-gov-east-1"  = "ami-0ae964892f34bc39b"
    "us-gov-west-1"  = "ami-07a34e5ccac5e0cb0"
    "us-east-2"      = "ami-0494d65a03ba42770"
    "us-west-1"      = "ami-0d136751414f6bf6d"
    "us-west-2"      = "ami-08c14f656742efba9"
    "ca-central-1"   = "ami-0d3e3f74ab95a37d7"
    "eu-central-1"   = "ami-0a9ca3989dc169286"
    "eu-west-1"      = "ami-080351e24e226763f"
    "eu-west-2"      = "ami-0a4867852ea5949b7"
    "eu-west-3"      = "ami-0da9f07c5e2c3fd57"
    "eu-north-1"     = "ami-03a3e77cb638b906f"
    "eu-south-1"     = "ami-0e4d41d344d862a16"
    "ap-southeast-1" = "ami-0ea66d49186af8d88"
    "ap-southeast-2" = "ami-05bd572125ebee64a"
    "ap-southeast-3" = "ami-0b57ca7c2ac040665"
    "ap-south-1"     = "ami-05abc56fd2ecc7eab"
    "ap-northeast-1" = "ami-09ab71d2560b838bc"
    "ap-northeast-2" = "ami-00dfc62baf2b0a285"
    "ap-northeast-3" = "ami-0e01535bf379a6530"
    "ap-east-1"      = "ami-09e3ca13d1723914c"
    "sa-east-1"      = "ami-07b803b7c752aed7e"
    "me-south-1"     = "ami-0dbf599ae0fbaf290"
    "af-south-1"     = "ami-0605cfc0c327bff3a"
  }
}

variable "veeam_aws_byol_edition_ami_map" {
  description = "AMI map for Veeam Backup for AWS BYOL edition"
  type        = map(any)
  default = {
    "us-east-1"      = "ami-0bd61a6e0d808e66d"
    "us-gov-east-1"  = "ami-051f70ceadd18ae09"
    "us-gov-west-1"  = "ami-00412d5ad25aadda5"
    "us-east-2"      = "ami-00e8a5367f484896a"
    "us-west-1"      = "ami-0089dade9b4b21f15"
    "us-west-2"      = "ami-018c76907cf55d021"
    "ca-central-1"   = "ami-09d9b9eb8146b8804"
    "eu-central-1"   = "ami-0e34fd587935b6d28"
    "eu-west-1"      = "ami-0b1bcebe0d7935b60"
    "eu-west-2"      = "ami-06189b56d5b201346"
    "eu-west-3"      = "ami-09407a04720562ab5"
    "eu-north-1"     = "ami-0ce2ba418e6d97d26"
    "eu-south-1"     = "ami-0cfe15c6d4d457a1d"
    "ap-southeast-1" = "ami-0375f9ecceac23d9b"
    "ap-southeast-2" = "ami-0bf8a21feac0bc1bc"
    "ap-southeast-3" = "ami-06e097778208083a8"
    "ap-south-1"     = "ami-03aaeae86af9accaf"
    "ap-northeast-1" = "ami-0e8088fa12e28c93e"
    "ap-northeast-2" = "ami-05461363fd566eba4"
    "ap-northeast-3" = "ami-028dcaf72393362b4"
    "ap-east-1"      = "ami-0950579997a0a54bf"
    "sa-east-1"      = "ami-046d22d10b7c0d92a"
    "me-south-1"     = "ami-0975073164922ad8d"
    "af-south-1"     = "ami-07799ea1c5129a74d"
  }
}

variable "veeam_aws_paid_edition_ami_map" {
  description = "AMI map for Veeam Backup for AWS paid edition"
  type        = map(any)
  default = {
    "us-east-1"      = "ami-02c037702d5552351"
    "us-gov-east-1"  = "ami-0d902ba471a08d01f"
    "us-gov-west-1"  = "ami-074e6840d78e58d7a"
    "us-east-2"      = "ami-046928baf812d6b30"
    "us-west-1"      = "ami-0afcb95e2c371f1ea"
    "us-west-2"      = "ami-0cadd3a466da0a707"
    "ca-central-1"   = "ami-0901ff715ddd44280"
    "eu-central-1"   = "ami-0abb412b9a3730f9d"
    "eu-west-1"      = "ami-07a2c25ed46220d53"
    "eu-west-2"      = "ami-005fc5a42d901f333"
    "eu-west-3"      = "ami-0e764d95fd48d1f9c"
    "eu-north-1"     = "ami-06a26df0b2137c71d"
    "eu-south-1"     = "ami-0d1c0059b7ed85d5e"
    "ap-southeast-1" = "ami-0a6b147f1f57649eb"
    "ap-southeast-2" = "ami-0e266a9eb1c672e7e"
    "ap-southeast-3" = "ami-05bfa325119334004"
    "ap-south-1"     = "ami-06ac1f48a113026ac"
    "ap-northeast-1" = "ami-034e84b649af76512"
    "ap-northeast-2" = "ami-0d71ee1bdb66b0e0a"
    "ap-northeast-3" = "ami-09585503c8a0eb911"
    "ap-east-1"      = "ami-07cc0b74eab451fab"
    "sa-east-1"      = "ami-052d4d50feeaf58c3"
    "me-south-1"     = "ami-0f9e18c64900b624b"
    "af-south-1"     = "ami-0b0efd2ee14829d1d"
  }
}
