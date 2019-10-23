provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}
resource "aws_vpc" "terraformmain" {
    cidr_block = "${var.vpc-ipv4-cidr}"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags {
      Name = "VEEAM-02"
    }
} 