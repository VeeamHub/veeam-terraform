variable "region" {
  default = "us-west-1"
}
variable "VeeamPNAMIImage" {
  type = "map"
  default = {
    us-west-1 = "ami-c16862a1"
    us-west-2 = "ami-4e79ed36"
  }
  description = "This is for the Veeam PN Instance Running on Ubuntu 16.04 LTS"
}

variable "VeeamRepoAMIImage" {
  type = "map"
  default = {
    us-west-1 = "ami-78485818"
    us-west-2 = "ami-0ebdd976"
  }
}
 
# This will Prompt you for AWS Access and Secret Key
variable "aws_access_key{}"
varibale "aws_secret_key{}"

# To hard code AWS Access and Secret Key comment above and uncomment below
#variable "aws_access_key" {
#  default = "ACCESS_KEY"
#  description = "User aws access key"
#}
#variable "aws_secret_key" {
#  default = "SECRET_KEY"
#  description = "User aws secret key"
#}

variable "vpc-ipv4-cidr" {
  default = "10.0.100.0/24"
  description = "The VPC ipv4 CDIR"
}
variable "vpc-subnet-cidr" {
  default = "10.0.100.0/24"
  description = "The CDIR of the subnet"
}
variable "key_name" {
  default = "KEY_NAME"
  description = "the ssh key to use in the EC2 machines. Needs to be created in AWS region first."
}

output "Public_IP_VeeamPN" {
  value = "${aws_instance.VeeamPN.public_ip}"
}

output "private_ip_VeeamPN" {
  value = "${aws_instance.VeeamPN.private_ip}"
}

output "private_ip_VeeamRepo" {
  value = "${aws_instance.VeeamRepo.private_ip}"
}