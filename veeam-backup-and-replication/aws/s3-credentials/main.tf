terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.61"
    }

    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.18.0"
    }
  }

  required_version = ">= 1.4.0"
}

provider "aws" {
  region = var.aws_region
}

provider "restapi" {
  uri                   = "https://${var.vbr_ip}:9419"
  alias                 = "vbr_rest_api"
  insecure              = true
  debug                 = true
  create_returns_object = true
  copy_keys             = ["id"]

  headers = {
    "Authorization" = "Bearer ${var.vbr_access_token}"
    "Content-Type"  = "application/json"
    "x-api-version" = "1.1-rev0" #v12 REST API version
  }

  test_path = "/api/v1/serverTime"
}


## Variables

variable "vbr_access_token" {
  type = string
}

variable "vbr_ip" {
  type = string
}

variable "aws_region" {
  type = string
}


## S3 resources

resource "aws_s3_bucket" "veeam_s3_bucket" {
  # IMPORTANT: The property `force_destroy` is set to `true`. The bucket and all contents will be deleted upon running a `terraform destory` command.
  # If you intend to use this bucket in production to store backup data, set the `force_destroy` property to `false`.
  force_destroy = true

  # IMPORTANT: If you enable object lock on the bucket, be aware that it will not be possible to
  # destroy the bucket until the retention period is met on any immutable backups you create.
  # Veeam uses Compliance mode for immutable backups stored in Amazon S3. More details in the user guide:
  # https://helpcenter.veeam.com/docs/backup/vsphere/object_storage_repository_cal.html#considerations-and-limitations-for-immutability
  # object_lock_enabled = true
}

resource "aws_s3_bucket_public_access_block" "veeam_s3_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.veeam_s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "veeam_s3_bucket_ownership_controls" {
  bucket = aws_s3_bucket.veeam_s3_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


## IAM resources

resource "aws_iam_policy" "veeam_s3_repo_user_policy_immutable" {
  name = "veeam-s3-repo-policy-immutable"
  path = "/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VeeamS3BucketPermissions",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetBucketVersioning",
          "s3:GetBucketObjectLockConfiguration",
          "s3:ListBucketVersions",
          "s3:GetObjectVersion",
          "s3:GetObjectRetention",
          "s3:GetObjectLegalHold",
          "s3:PutObjectRetention",
          "s3:PutObjectLegalHold",
          "s3:DeleteObjectVersion"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.veeam_s3_bucket.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.veeam_s3_bucket.bucket}"
        ]
      },
      {
        "Sid" : "VeeamS3Permissions",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListAllMyBuckets",
          "s3:ListBucket"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_user" "veeam_s3_repo_user" {
  name = "veeam-s3-repo-user"
}

resource "aws_iam_user_policy_attachment" "veeam_s3_repo_user_policy_attachment" {
  user       = aws_iam_user.veeam_s3_repo_user.name
  policy_arn = aws_iam_policy.veeam_s3_repo_user_policy_immutable.arn
}

resource "aws_iam_access_key" "veeam_s3_repo_user_access_key" {
  user = aws_iam_user.veeam_s3_repo_user.name
}

## IAM policies for EC2 helper appliance for S3 repositories

resource "aws_iam_policy" "veeam_ec2_helper_policy" { #
  name = "veeam-ec2-helper-policy"
  path = "/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VeeamEc2Helper",
        "Action" : [
          "ec2:DescribeInstances",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:ModifyInstanceAttribute",
          "ec2:DescribeImages",
          "ec2:ImportImage",
          "ec2:DeregisterImage",
          "ec2:DescribeVolumes",
          "ec2:CreateVolume",
          "ec2:ModifyVolume",
          "ec2:ImportVolume",
          "ec2:DeleteVolume",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:CreateSnapshot",
          "ec2:DescribeSnapshots",
          "ec2:DeleteSnapshot",
          "ec2:DescribeSubnets",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeKeyPairs",
          "ec2:CreateKeyPair",
          "ec2:DeleteKeyPair",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeVpcs",
          "ec2:DescribeConversionTasks",
          "ec2:DescribeImportImageTasks",
          "ec2:DescribeVolumesModifications",
          "ec2:CancelImportTask",
          "ec2:CancelConversionTask",
          "ec2:CreateTags",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeVpcAttribute",
          "iam:GetRole",
          "iam:CreateRole",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "ssm:SendCommand",
          "ssm:DescribeInstanceInformation",
          "ssm:UpdateManagedInstanceRole",
          "ssm:GetCommandInvocation",
          "iam:PassRole",
          "iam:AddRoleToInstanceProfile",
          "iam:CreateInstanceProfile",
          "iam:AttachRolePolicy",
          "iam:SimulatePrincipalPolicy",
          "ec2:AssociateIamInstanceProfile",
          "ec2:DescribeIamInstanceProfileAssociations",
          "sqs:*",
          "iam:GetPolicyVersion",
          "iam:DeleteAccessKey",
          "iam:GetPolicy",
          "iam:AttachUserPolicy",
          "iam:DeleteUserPolicy",
          "iam:DeletePolicy",
          "iam:DeleteUser",
          "iam:ListUserPolicies",
          "iam:CreateUser",
          "iam:TagUser",
          "iam:CreateAccessKey",
          "iam:CreatePolicy",
          "iam:ListPolicyVersions",
          "iam:GetUserPolicy",
          "iam:PutUserPolicy",
          "iam:ListAttachedUserPolicies",
          "iam:GetUser",
          "iam:CreatePolicyVersion",
          "iam:DetachUserPolicy",
          "iam:DeletePolicyVersion",
          "iam:ListAccessKeys",
          "iam:SetDefaultPolicyVersion"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "veeam_ec2_helper_policy_attachment" {
  user       = aws_iam_user.veeam_s3_repo_user.name
  policy_arn = aws_iam_policy.veeam_ec2_helper_policy.arn
}


## VBR REST API resources

resource "restapi_object" "veeam_s3_cloud_credential" {
  depends_on = [
    aws_iam_access_key.veeam_s3_repo_user_access_key
  ]
  provider = restapi.vbr_rest_api
  debug    = true
  path     = "/api/v1/cloudCredentials"
  data = jsonencode({
    "description" : "veeam-s3-repo-credentials",
    "type" : "Amazon",
    "accessKey" : aws_iam_access_key.veeam_s3_repo_user_access_key.id,
    "secretKey" : aws_iam_access_key.veeam_s3_repo_user_access_key.secret,
    "tag" : "veeam-s3-repo-credentials-tag"
  })
}

resource "restapi_object" "veeam_s3_cloud_credential_secret" {
  depends_on = [
    restapi_object.veeam_s3_cloud_credential
  ]
  provider = restapi.vbr_rest_api
  debug    = true
  path     = "/api/v1/cloudCredentials/${restapi_object.veeam_s3_cloud_credential.id}/changeSecretKey"
  data = jsonencode({
    "newSecretKey" : aws_iam_access_key.veeam_s3_repo_user_access_key.secret,
  })

  update_path   = "/api/v1/cloudCredentials/${restapi_object.veeam_s3_cloud_credential.id}/changeSecretKey"
  update_method = "POST"
  update_data = jsonencode({
    "newSecretKey" : aws_iam_access_key.veeam_s3_repo_user_access_key.secret
  })
}


## Outputs

output "veeam_s3_cloud_credential_id" {
  value = restapi_object.veeam_s3_cloud_credential.id
}
