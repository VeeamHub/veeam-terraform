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

# Specify the IAM role which you want to have access to the bucket.
admin_role = ""

# Specify the IAM user which you want to have access to the bucket.
admin_user = ""
