# Deploy Veeam Backup for AWS with Terraform

## Overview

This folder contains a sample project for deploying Veeam Backup for AWS using Terraform.

## Requirements

- [Terraform](https://www.terraform.io/downloads) (>= 1.2)
- AWS account [configured for use with Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)
- An active AWS Marketplace subscription to the edition of Veeam Backup for AWS you will deploy

## Walkthrough

1) Clone this repository to your system. Details on cloning remote repositories are located in the [GitHub docs](https://docs.github.com/en/get-started/getting-started-with-git/about-remote-repositories). You can also download the repository in ZIP format and extract locally.

   ```shell
   git clone https://github.com/VeeamHub/veeam-terraform.git
   ```

1) Change your directory to the `deploy_vbaws` folder located a couple levels inside the repository root.

   ```shell
   cd veeam-terraform/veeam-backup-aws/deploy_vbaws
   ```

1) Run the [init](https://www.terraform.io/cli/commands/init) command to initialize the Terraform deployment and set up the providers.

   ```shell
   terraform init
   ```

1) A `variables.tf` file is included that defines multiple variables used for the deployment. To customize your deployment, open the `terraform.tfvars` file and plug in your values.

   The variables and valid inputs are described in the files themselves.

   > **IMPORTANT**
   >
   > The template includes a bucket policy that locks down which identities can access or perform any action on the bucket that will hold backup repositories. This is an optional security hardening measure.
   >
   > Use special care and attention with these values as incorrect usage could result in the deployment creating a bucket which is inaccessible by anyone except the account's root user. Refer to the following AWS support article if you encounter issues: [Regain access to an Amazon S3 bucket](https://aws.amazon.com/premiumsupport/knowledge-center/s3-accidentally-denied-access/)
   >
   > Alternatively, you can remove the bucket policy resource from `main.tf` and the `admin_role_id` and `admin_user_id` variables in `variables.tf`.

1) The deployment includes multiple IAM managed policies that are attached to the `veeam-aws-default-role` IAM role. These policies allow you to perform backup and restore operations for all supported AWS services. More details on the policies are located in the [IAM Permissions](https://helpcenter.veeam.com/docs/vbaws/guide/system_requirements_permissions.html) section of the Veeam Backup for AWS user guide.

   If you'd like to test only specific services, open the `main.tf` file and comment out (the `#` character denotes comments) or remove the relevant `aws_iam_policy` and `aws_iam_role_policy_attachment` resources.

1) The next step is running a [plan](https://www.terraform.io/cli/commands/plan) command to preview what will be created and ensure your deployment will run smoothly.

   ```shell
   terraform plan
   ```

1) If your values are valid, you're ready to go. Run the [apply](https://www.terraform.io/cli/commands/apply) command to provision the resources.

   ```shell
   terraform apply
   ```

1) The command output includes the EC2 instance ID you will need to complete the initial setup. For more details on setup, visit the [After You Install](https://helpcenter.veeam.com/docs/vbaws/guide/initial_configuration.html) section in the Veeam Backup for AWS user guide.

1) Here are a few resources to assist you in your use of Veeam Backup for AWS.
   - [Veeam Backup for AWS product page](https://www.veeam.com/aws-backup.html)
   - [Veeam Backup for AWS user guide](https://helpcenter.veeam.com/docs/vbaws/guide/)
   - [Best Practice Guide for Veeam Backup for Public Cloud Solutions](https://bp.veeam.com/vbcloud)

1) When your testing or use is complete, run the [destroy](https://www.terraform.io/cli/commands/destroy) command to delete all resources that were created in the deployment.

   > **IMPORTANT**
   >
   > The bucket created by this deployment and all its contents will be deleted permanently upon running the `destroy` command.
   >
   > Follow the instructions in the [Managing Backed-Up Data](https://helpcenter.veeam.com/docs/vbaws/guide/backups_view.html) section in the Veeam Backup for AWS user guide to remove any snapshots _before_ you run the `destroy` command. The `destroy` command does not remove any snapshots that are created during the testing of backup policies.

   ```shell
   terraform destroy
   ```

## Questions and Feedback

If you have any questions or feedback, don't hesitate to [create an issue](https://github.com/VeeamHub/veeam-terraform/issues/new/choose) and share your ideas and comments.
