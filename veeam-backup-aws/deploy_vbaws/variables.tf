variable "aws_region" {
  description = "AWS region"
  type        = string

  validation {
    condition     = contains(["us-east-1", "us-gov-east-1", "us-gov-west-1", "us-east-2", "us-west-1", "us-west-2", "ca-central-1", "eu-central-1", "eu-west-1", "eu-west-2", "eu-west-3", "eu-north-1", "eu-south-1", "ap-southeast-1", "ap-southeast-2", "ap-southeast-3", "ap-south-1", "ap-northeast-1", "ap-northeast-2", "ap-northeast-3", "ap-east-1", "sa-east-1", "me-south-1", "af-south-1", "ap-southeast-4", "ap-south-2", "eu-south-2", "eu-central-2", "me-central-2"], var.aws_region)
    error_message = "Unsupported region. Please choose a supported region: us-east-1, us-gov-east-1, us-gov-west-1, us-east-2, us-west-1, us-west-2, ca-central-1, eu-central-1, eu-west-1, eu-west-2, eu-west-3, eu-north-1, eu-south-1, ap-southeast-1, ap-southeast-2, ap-southeast-3, ap-south-1, ap-northeast-1, ap-northeast-2, ap-northeast-3, ap-east-1, sa-east-1, me-south-1, af-south-1, ap-southeast-4, ap-south-2, eu-south-2, eu-central-2, me-central-2"
  }
}

variable "veeam_aws_instance_type" {
  description = "Instance type for the Veeam Backup for AWS appliance"
  type        = string
  default     = "t2.medium"

  validation {
    condition     = contains(["t2.medium", "t2.large", "t2.xlarge", "t2.2xlarge", "t3.medium", "t3.large", "t3.xlarge", "t3.2xlarge", "c5.large", "c5.2xlarge", "c5.4xlarge", "c5.9xlarge"], var.veeam_aws_instance_type)
    error_message = "Unsupported instance type. Please choose a supported instance type from the following list: t2.medium, t2.large, t2.xlarge, t2.2xlarge, t3.medium, t3.large, t3.xlarge, t3.2xlarge, c5.large, c5.2xlarge, c5.4xlarge, c5.9xlarge ."
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

variable "admin_role" {
  description = "Name of the IAM role that will have access to the Veeam S3 bucket"
  type        = string
}

variable "admin_user" {
  description = "Name of the IAM user that will have access to the Veeam S3 bucket"
  type        = string
}
