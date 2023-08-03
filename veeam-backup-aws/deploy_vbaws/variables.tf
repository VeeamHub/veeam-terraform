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

### DO NOT EDIT THE FOLLOWING ami_map VARIABLES!
### AMI maps for the available editions of Veeam Backup for AWS.

variable "veeam_aws_free_edition_ami_map" {
  description = "AMI map for Veeam Backup for AWS free edition"
  type        = map(any)
  default = {
    "us-east-1"      = "ami-0c4de786a14c0fd3d"
    "us-gov-east-1"  = "ami-0dc6c0fb56ac270c8"
    "us-gov-west-1"  = "ami-08f4945071dd34c37"
    "us-east-2"      = "ami-0e95403cdfa31f54f"
    "us-west-1"      = "ami-0fd5eb41ce32188b4"
    "us-west-2"      = "ami-06deea83b05436966"
    "ca-central-1"   = "ami-079b0b4d3e7430496"
    "eu-central-1"   = "ami-02a834069806bfc5b"
    "eu-west-1"      = "ami-03d706d9d97ef4f89"
    "eu-west-2"      = "ami-0ac185ae838e75f75"
    "eu-west-3"      = "ami-056584a6d73bfb12c"
    "eu-north-1"     = "ami-08a0fc791674fe3f3"
    "eu-south-1"     = "ami-01652cf9a75f5a7cb"
    "ap-southeast-1" = "ami-032e4853bde181381"
    "ap-southeast-2" = "ami-0b6c76b1ee2570a7f"
    "ap-southeast-3" = "ami-06b9511cafa44a5d6"
    "ap-south-1"     = "ami-0ddf378296fa2607d"
    "ap-northeast-1" = "ami-0da79b7e129d726d8"
    "ap-northeast-2" = "ami-000cc6a1c2e6be353"
    "ap-northeast-3" = "ami-0d5e4e6b39fed4779"
    "ap-east-1"      = "ami-07d89a13ca0f1e6fd"
    "sa-east-1"      = "ami-0a295dfe43fc03ad0"
    "me-south-1"     = "ami-0aa3bc2bbca3b0688"
    "af-south-1"     = "ami-028290c356d626b4a"
    "ap-southeast-4" = "ami-0747e0431011e0081"
    "ap-south-2"     = "ami-09e0e6517c06e97f2"
    "eu-south-2"     = "ami-0ea4d1bb3dbd6a702"
    "eu-central-2"   = "ami-0d435c123857c4fe6"
    "me-central-1"   = "ami-0b86636d96db0c8ca"
  }
}

variable "veeam_aws_byol_edition_ami_map" {
  description = "AMI map for Veeam Backup for AWS BYOL edition"
  type        = map(any)
  default = {
    "us-east-1"      = "ami-0080d5dc2ebd92bf4"
    "us-gov-east-1"  = "ami-002aff98490491993"
    "us-gov-west-1"  = "ami-053ed6f75a760b8ec"
    "us-east-2"      = "ami-0714b94769c7e908a"
    "us-west-1"      = "ami-002cf06e81b5ce794"
    "us-west-2"      = "ami-040af1e125000b2d1"
    "ca-central-1"   = "ami-0d3ae080411456061"
    "eu-central-1"   = "ami-0d381befae8b95965"
    "eu-west-1"      = "ami-0f0833f1ef827d161"
    "eu-west-2"      = "ami-0100eb0352777d435"
    "eu-west-3"      = "ami-0c01ef9a8991269fb"
    "eu-north-1"     = "ami-01743137f2b8fefc5"
    "eu-south-1"     = "ami-0f7b1d366b2406855"
    "ap-southeast-1" = "ami-0a54eced8f7293d68"
    "ap-southeast-2" = "ami-0ffa20f16716f4318"
    "ap-southeast-3" = "ami-0f2a8f89057eafadc"
    "ap-south-1"     = "ami-05bde69f106740c8a"
    "ap-northeast-1" = "ami-0910eab67428f222b"
    "ap-northeast-2" = "ami-0e5d1a2061e3e6ca6"
    "ap-northeast-3" = "ami-0360d8300bbcc9e41"
    "ap-east-1"      = "ami-02a211fde161d77f7"
    "sa-east-1"      = "ami-04f8b7b97081b2395"
    "me-south-1"     = "ami-046e0f1749fd5c3e8"
    "af-south-1"     = "ami-0cececfbc24009656"
    "ap-southeast-4" = "ami-09da1609614a18642"
    "ap-south-2"     = "ami-0eb9ee172891339ef"
    "eu-south-2"     = "ami-00b6aed2d31e3385f"
    "eu-central-2"   = "ami-093cb771240dc5f92"
    "me-central-1"   = "ami-059ac269f50f89b4a"
  }
}

variable "veeam_aws_paid_edition_ami_map" {
  description = "AMI map for Veeam Backup for AWS paid edition"
  type        = map(any)
  default = {
    "us-east-1"      = "ami-0416006f399281394"
    "us-gov-east-1"  = "ami-025af4d3f9808a0f5"
    "us-gov-west-1"  = "ami-0a161af390561ff2c"
    "us-east-2"      = "ami-0d9299c00922f79b1"
    "us-west-1"      = "ami-0e983256c1a134560"
    "us-west-2"      = "ami-09c0261ce4239f2fe"
    "ca-central-1"   = "ami-0813b66945827aae3"
    "eu-central-1"   = "ami-021d9bdcf875d1533"
    "eu-west-1"      = "ami-0c83a37c022090429"
    "eu-west-2"      = "ami-0891bbfaebdcd0232"
    "eu-west-3"      = "ami-0c389f30e05c62db2"
    "eu-north-1"     = "ami-05c4fded168d5c314"
    "eu-south-1"     = "ami-0f413f0e4402ab499"
    "ap-southeast-1" = "ami-0d3d34ebe9e96a23d"
    "ap-southeast-2" = "ami-035765b25ce7b8ac2"
    "ap-southeast-3" = "ami-0df07a9e3b35405f0"
    "ap-south-1"     = "ami-047913abf8c404655"
    "ap-northeast-1" = "ami-088263bccf9115156"
    "ap-northeast-2" = "ami-0184489efb0f3116e"
    "ap-northeast-3" = "ami-0dd4c3e80cc50bf97"
    "ap-east-1"      = "ami-009b564f1880eba31"
    "sa-east-1"      = "ami-050d4975133a98707"
    "me-south-1"     = "ami-042c9e09623849daa"
    "af-south-1"     = "ami-0b1d2bd1d5f41c0d2"
    "ap-southeast-4" = "ami-09bde014e7064b889"
    "ap-south-2"     = "ami-02a62476f9546650b"
    "eu-south-2"     = "ami-003588d0c9b518f0f"
    "eu-central-2"   = "ami-07d6911e758a808f9"
    "me-central-1"   = "ami-02bac97317d776efc"
  }
}
