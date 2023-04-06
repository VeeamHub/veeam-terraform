# Manage Veeam S3 credentials with Terraform

## Overview

This folder contains a sample project for managing S3 credentials in Veeam with Terraform.

## Requirements

- [Terraform](https://www.terraform.io/downloads) (>= 1.4)
- AWS account [configured for use with Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)

## Walkthrough

1) Clone this repository to your system. Details on cloning remote repositories are located in the [GitHub docs](https://docs.github.com/en/get-started/getting-started-with-git/about-remote-repositories). You can also download the repository in ZIP format and extract locally.

   ```shell
   git clone https://github.com/VeeamHub/veeam-terraform.git
   ```

1) Navigate to the `veeam-backup-and-replication/aws/s3-credentials` directory.

   ```shell
   cd veeam-terraform/veeam-backup-and-replication/aws/s3-credentials
   ```

1) Run the [init](https://www.terraform.io/cli/commands/init) command to initialize the Terraform deployment and set up the providers.

   ```shell
   terraform init
   ```

1) You will need to supply 3 variables to Terraform to run the deployment:

   1) AWS region where you want to create your S3 bucket
   1) IP address of your VBR server
   1) Access token for your VBR REST API

   For details on how to generate an access token for the VBR REST API, visit the [Veeam Backup & Replication REST API Reference Guide](https://helpcenter.veeam.com/docs/backup/vbr_rest/requesting_authorization.html).

1) The next step is running a [plan](https://www.terraform.io/cli/commands/plan) command to preview what will be created and ensure your deployment will run smoothly.

   ```shell
   terraform plan
   ```

1) If your values are valid, you're ready to go. Run the [apply](https://www.terraform.io/cli/commands/apply) command to provision the resources.

   ```shell
   terraform apply
   ```

1) You can rotate your AWS access key by using Terraform's replace option on the `aws_iam_access_key` resource. More information is available in the [Terraform docs](https://developer.hashicorp.com/terraform/cli/commands/plan#replace-address).

   When you rotate the access key in AWS, it will also update the cloud credential in Veeam Backup & Replication.

1) If you would like to remove the resources, run the [destroy](https://www.terraform.io/cli/commands/destroy) command to delete all resources that were created in the deployment, including the cloud credential in Veeam Backup & Replication.

   > **IMPORTANT**
   >
   > The bucket created by this deployment and all its contents will be deleted permanently upon running the `destroy` command.
   >
   > If you would like to keep the data after destroying the deployment, set the `force_destroy` property to _false_ in the bucket resource definition.

   ```shell
   terraform destroy
   ```

## Questions and Feedback

If you have any questions or feedback, don't hesitate to [create an issue](https://github.com/VeeamHub/veeam-terraform/issues/new/choose) and share your ideas and comments.
