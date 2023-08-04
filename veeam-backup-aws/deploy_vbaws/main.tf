terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.30"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.aws_region
}

## Get AMI IDs using AMI alias from SSM parameter store

data "aws_ssm_parameter" "veeam_aws_instance_ami_free" {
  name = "/aws/service/marketplace/prod-i6cc2jepj6py2/6.1.0.25"
}

data "aws_ssm_parameter" "veeam_aws_instance_ami_byol" {
  name = "/aws/service/marketplace/prod-66kpsz7advwp4/6.1.0.25"
}

data "aws_ssm_parameter" "veeam_aws_instance_ami_paid" {
  name = "/aws/service/marketplace/prod-amqo533wfzacq/6.1.0.25"
}

## Set AMI ID value based on veeam_aws_edition variable

locals {
  veeam_aws_instance_ami      = var.veeam_aws_edition == "byol" ? data.aws_ssm_parameter.veeam_aws_instance_ami_byol.value : (var.veeam_aws_edition == "free" ? data.aws_ssm_parameter.veeam_aws_instance_ami_free.value : data.aws_ssm_parameter.veeam_aws_instance_ami_paid.value)
}

### IAM Resources

data "aws_iam_policy_document" "veeam_aws_instance_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "veeam_aws_instance_role_inline_policy" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "veeam_aws_instance_role" {
  name               = "veeam-aws-instance-role"
  assume_role_policy = data.aws_iam_policy_document.veeam_aws_instance_role_assume_policy.json

  inline_policy {
    name   = "veeam-aws-instance-policy"
    policy = data.aws_iam_policy_document.veeam_aws_instance_role_inline_policy.json
  }
}

resource "aws_iam_instance_profile" "veeam_aws_instance_profile" {
  name = "veeam-aws-instance-profile"
  role = aws_iam_role.veeam_aws_instance_role.name
}

data "aws_iam_policy_document" "veeam_aws_default_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.veeam_aws_instance_role.arn]
    }
  }
}

resource "aws_iam_role" "veeam_aws_default_role" {
  name               = "veeam-aws-default-role"
  assume_role_policy = data.aws_iam_policy_document.veeam_aws_default_role_assume_policy.json
}

resource "aws_iam_policy" "veeam_aws_service_policy" {
  name        = "veeam-aws-service-policy"
  description = "Veeam Backup for AWS permissions to launch worker instances to perform backup and restore operations."

  policy = file("veeam-aws-service-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_service_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_service_policy.arn
}

resource "aws_iam_policy" "veeam_aws_repository_policy" {
  name        = "veeam-aws-repository-policy"
  description = "Veeam Backup for AWS permissions to create backup repositories in an Amazon S3 bucket and to access the repository when performing backup and restore operations."

  policy = file("veeam-aws-repository-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_repository_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_repository_policy.arn
}

## Backup policies

resource "aws_iam_policy" "veeam_aws_ec2_backup_policy" {
  name        = "veeam-aws-ec2-backup-policy"
  description = "Veeam Backup for AWS permissions to execute policies for EC2 data protection."

  policy = file("veeam-aws-ec2-backup-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_ec2_backup_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_ec2_backup_policy.arn
}

resource "aws_iam_policy" "veeam_aws_rds_backup_policy" {
  name        = "veeam-aws-rds-backup-policy"
  description = "Veeam Backup for AWS permissions to execute policies for RDS data protection."

  policy = file("veeam-aws-rds-backup-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_rds_backup_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_rds_backup_policy.arn
}

resource "aws_iam_policy" "veeam_aws_efs_backup_policy" {
  name        = "veeam-aws-efs-backup-policy"
  description = "Veeam Backup for AWS permissions to execute policies for EFS data protection."

  policy = file("veeam-aws-efs-backup-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_efs_backup_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_efs_backup_policy.arn
}

resource "aws_iam_policy" "veeam_aws_vpc_backup_policy" {
  name        = "veeam-aws-vpc-backup-policy"
  description = "Veeam Backup for AWS permissions to execute policies for VPC configuration backup."

  policy = file("veeam-aws-vpc-backup-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_vpc_backup_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_vpc_backup_policy.arn
}

## Restore policies

resource "aws_iam_policy" "veeam_aws_ec2_restore_policy" {
  name        = "veeam-aws-ec2-restore-policy"
  description = "Veeam Backup for AWS permissions to perform EC2 restore operations."

  policy = file("veeam-aws-ec2-restore-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_ec2_restore_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_ec2_restore_policy.arn
}

resource "aws_iam_policy" "veeam_aws_rds_restore_policy" {
  name        = "veeam-aws-rds-restore-policy"
  description = "Veeam Backup for AWS permissions to perform RDS restore operations."

  policy = file("veeam-aws-rds-restore-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_rds_restore_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_rds_restore_policy.arn
}

resource "aws_iam_policy" "veeam_aws_efs_restore_policy" {
  name        = "veeam-aws-efs-restore-policy"
  description = "Veeam Backup for AWS permissions to perform EFS restore operations."

  policy = file("veeam-aws-efs-restore-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_efs_restore_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_efs_restore_policy.arn
}

resource "aws_iam_policy" "veeam_aws_vpc_restore_policy" {
  name        = "veeam-aws-vpc-restore-policy"
  description = "Veeam Backup for AWS permissions to perform VPC configuration restore operations."

  policy = file("veeam-aws-vpc-restore-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_vpc_restore_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_vpc_restore_policy.arn
}

resource "aws_iam_role" "veeam_aws_dlm_role" {
  name = "veeam-aws-dlm-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",      
      "Principal": {
        "Service": "dlm.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "veeam_aws_dlm_role_policy" {
  name = "veeam-aws-dlm-role-policy"
  role = aws_iam_role.veeam_aws_dlm_role.id

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateSnapshot",
            "ec2:CreateSnapshots",
            "ec2:DescribeInstances",
            "ec2:DescribeVolumes",
            "ec2:DescribeSnapshots"
         ],
         "Resource": "*"
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateTags",
            "ec2:DeleteSnapshot"
         ],
         "Resource": "arn:aws:ec2:*::snapshot/*"
      }
   ]
}
EOF
}

### VPC Resources

resource "aws_vpc" "veeam_aws_vpc" {
  cidr_block           = var.vpc_cidr_block_ipv4
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "veeam-aws-vpc"
  }
}

resource "aws_internet_gateway" "veeam_aws_igw" {
  tags = {
    Name = "veeam-aws-igw"
  }
}

resource "aws_internet_gateway_attachment" "veeam_aws_igw_attachment" {
  internet_gateway_id = aws_internet_gateway.veeam_aws_igw.id
  vpc_id              = aws_vpc.veeam_aws_vpc.id
}

resource "aws_route_table" "veeam_aws_route_table" {
  vpc_id = aws_vpc.veeam_aws_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.veeam_aws_igw.id
  }

  tags = {
    Name = "veeam-aws-rt"
  }
}

resource "aws_route_table_association" "veeam_aws_route_table_association" {
  subnet_id      = aws_subnet.veeam_aws_subnet.id
  route_table_id = aws_route_table.veeam_aws_route_table.id
}

resource "aws_subnet" "veeam_aws_subnet" {
  vpc_id                  = aws_vpc.veeam_aws_vpc.id
  cidr_block              = var.subnet_cidr_block_ipv4
  map_public_ip_on_launch = true

  tags = {
    Name = "veeam-aws-subnet"
  }
}

resource "aws_security_group" "veeam_aws_security_group" {
  name        = "veeam-aws-security-group"
  description = "Access to Veeam Backup for AWS appliance"
  vpc_id      = aws_vpc.veeam_aws_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.veeam_aws_security_group]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "veeam_aws_s3_endpoint" {
  vpc_id            = aws_vpc.veeam_aws_vpc.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids   = [aws_route_table.veeam_aws_route_table.id]
}

resource "aws_eip" "veeam_aws_eip" {
  count = var.elastic_ip ? 1 : 0
  vpc   = true
}

resource "aws_eip_association" "veeam_aws_eip_association" {
  count         = var.elastic_ip ? 1 : 0
  instance_id   = aws_instance.veeam_aws_instance.id
  allocation_id = aws_eip.veeam_aws_eip[0].id
}

### EC2 Resources

resource "aws_instance" "veeam_aws_instance" {
  ami                    = local.veeam_aws_instance_ami
  instance_type          = var.veeam_aws_instance_type
  iam_instance_profile   = aws_iam_instance_profile.veeam_aws_instance_profile.name
  subnet_id              = aws_subnet.veeam_aws_subnet.id
  vpc_security_group_ids = [aws_security_group.veeam_aws_security_group.id]

  tags = {
    Name = "veeam-aws-demo"
  }

  user_data = join("\n", [aws_iam_role.veeam_aws_instance_role.arn, aws_iam_role.veeam_aws_default_role.arn])
}

### CloudWatch alarms and Data Lifecycle Manager policy

resource "aws_cloudwatch_metric_alarm" "veeam_aws_recovery_alarm" {
  alarm_name          = "veeam-aws-recovery-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "0"
  alarm_description   = "Trigger a recovery when system status check fails for 15 consecutive minutes."
  alarm_actions       = ["arn:aws:automate:${var.aws_region}:ec2:recover"]
  dimensions          = { InstanceId : aws_instance.veeam_aws_instance.id }
}

resource "aws_cloudwatch_metric_alarm" "veeam_aws_reboot_alarm" {
  alarm_name          = "veeam-aws-reboot-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "StatusCheckFailed_Instance"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "0"
  alarm_description   = "Trigger a reboot when instance status check fails for 3 consecutive minutes."
  alarm_actions       = ["arn:aws:automate:${var.aws_region}:ec2:reboot"]
  dimensions          = { InstanceId : aws_instance.veeam_aws_instance.id }
}

resource "aws_dlm_lifecycle_policy" "veeam_aws_dlm_lifecycle_policy" {
  description        = "DLM policy for the Veeam Backup for AWS EC2 instance"
  execution_role_arn = aws_iam_role.veeam_aws_dlm_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["INSTANCE"]

    schedule {
      name = "Daily snapshots"

      create_rule {
        interval      = 12
        interval_unit = "HOURS"
        times         = ["03:00"]
      }

      retain_rule {
        count = 1
      }

      tags_to_add = {
        type = "VcbDailySnapshot"
      }

      copy_tags = true
    }

    target_tags = {
      Name = "veeam-aws-demo"
    }
  }
}

### S3 bucket to store Veeam backups

resource "random_id" "veeam_aws_bucket_name_random_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "veeam_aws_bucket" {
  bucket = "veeam-aws-bucket-demo-${lower(random_id.veeam_aws_bucket_name_random_suffix.hex)}"

  force_destroy = true
  # IMPORTANT! The bucket and all contents will be deleted upon running a `terraform destory` command

}

resource "aws_s3_bucket_public_access_block" "veeam_aws_bucket_public_access_block" {
  bucket = aws_s3_bucket.veeam_aws_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "veeam_aws_bucket_ownership_controls" {
  bucket = aws_s3_bucket.veeam_aws_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

### S3 bucket lockdown

resource "aws_s3_bucket_policy" "veeam_aws_bucket_lockdown_policy" {
  bucket = aws_s3_bucket.veeam_aws_bucket.id
  policy = data.aws_iam_policy_document.veeam_aws_bucket_lockdown_policy_document.json
}

data "aws_iam_role" "admin_role_id" {
  name = var.admin_role
}

data "aws_iam_user" "admin_user_id" {
  user_name = var.admin_user
}

data "aws_iam_policy_document" "veeam_aws_bucket_lockdown_policy_document" {
  statement {
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.veeam_aws_bucket.arn,
      "${aws_s3_bucket.veeam_aws_bucket.arn}/*",
    ]

    condition {
      test     = "StringNotLike"
      variable = "aws:userId"

      values = [
        "${data.aws_iam_role.admin_role_id.unique_id}:*",
        data.aws_iam_user.admin_user_id.user_id,
        "${aws_iam_role.veeam_aws_default_role.unique_id}:*"
      ]
    }
  }
}

### Outputs

output "veeam_aws_instance_id" {
  description = "The instance ID of the Veeam Backup for AWS EC2 instance"
  value       = aws_instance.veeam_aws_instance.id
}

output "veeam_aws_instance_role_arn" {
  description = "The ARN of the instance role attached to the Veeam Backup for AWS EC2 instance"
  value       = aws_iam_role.veeam_aws_instance_role.arn
}

output "veeam_aws_bucket_name" {
  description = "The name of the provisioned S3 bucket"
  value       = aws_s3_bucket.veeam_aws_bucket.id
}

output "veeam_aws_instance_public_ip" {
  description = "The public IP address of the Veeam Backup for AWS EC2 instance"
  value       = aws_instance.veeam_aws_instance.public_ip
}
