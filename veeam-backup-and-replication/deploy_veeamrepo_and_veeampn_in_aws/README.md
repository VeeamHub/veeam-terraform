# Automated deployment of Veeam Repo and Veeam PN into AWS VPC

Author: Anthony Spiteri

Description: POC for Automated deployment of Veeam Linux Repository and Veeam PN Site Gateway into AWS VPC for use as offsite Veeam Backup & Replication storage. 

Function: Using Terraform to automate the creation a new VPC and two EC2 instances and configuring the required network settings and rules. The EC2 instances consist of an Ubuntu AMI to run Veeam PN and a CentOS AMI to act as the Veeam Linux Repository.

Pre-Requisites: There are a few requirements and pre-requisites that need to be in place before launching the Terraform plan.

* Download Terraform executable and place into working folder
* Create new Key Pair within desired region and download the Private key and place in working folder
* Create VeeamPN Site Configuration from HUB and download site XML configuration file

Variables: There are some variables that can be adjustment or need specifying.

* Set Region in VARIABLES.tf as desired
* Set AMI template ID for Ubuntu and CentOS in VARIABLES.tf
* Set VPC Subnet CIDRs in VARIABLES.tf as desired
* Set AWS Access and Secret Key into VARIABLES.tf (Default is set to prompt)
* Set the size of the Veeam Linux Repo hard disk in EC2-INSTANCES.tf
* Set the name of the Private Key pem file in EC2-INSTANCES.tf

Usage: ./terraform plan|apply|destroy

eg. echo yes | ./terraform apply

Final Tasks: After Terraform plan execution the EC2 instances will be configured with public IP addresses and accessible from the internet via SSH with the matched key pair. The output from the Terraform plan will show the Public IP of the Veeam PN Site Gateway. To Complete the setup, open a Web Browser and head to the IP of the Veeam PN instance. Username and password is set in configure.sh. Final step is to import the XML config to connect the Veeam PN Site Gateway to the HUB. Once done the Veeam Repo instance can be connected to and setup as a Veeam Linux Repository.
