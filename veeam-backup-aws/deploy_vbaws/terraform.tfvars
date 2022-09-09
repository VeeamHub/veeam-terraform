# Specify the AWS region where resources will be deployed.
# For the list of supported regions, review the aws_region variable in the variables.tf file.
aws_region = ""

# Specify the appliance instance type.
# For the list of supported instance types, review the veeam_aws_instance_type variable in the variables.tf file.
# Default is t2.medium.
veeam_aws_instance_type = ""

# Specify true or false if you want an Elastic IP created and associated with the appliance.
# Default is false.
elastic_ip = false

# CIDR block for the new VPC where the appliance will be deployed.
vpc_cidr_block_ipv4 = ""

# CIDR block for the subnet inside the VPC where the appliance will be deployed.
subnet_cidr_block_ipv4 = ""

# Specify the CIDR block that will be allowed to access the appliance on TCP/443 (HTTPS)
veeam_aws_security_group = ""

# Choose the edition of Veeam Backup for AWS you would like to deploy: free, byol, paid. 
# Default is free.
veeam_aws_edition = ""

# Specify the unique role ID (will look like AROA*) for an IAM role which you want to have access to the bucket.
# You can obtain this value using the AWS CLI or AWS CloudShell by running the following command:
# aws iam get-role --role-name <IAM role name> --query Role.RoleId
admin_role_id = ""

# Specify the unique user ID (will look like AIDA*) for an IAM user which you want to have access to the bucket.
# You can obtain this value using the AWS CLI or AWS CloudShell by running the following command:
# aws iam get-user --user-name <IAM user name> --query User.UserId
admin_user_id = ""
