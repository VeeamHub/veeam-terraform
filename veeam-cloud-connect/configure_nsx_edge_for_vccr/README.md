# Automated Configuration of vCD NSX Edge in Cloud Connect Replication

Author: Anthony Spiteri

https://wp.me/p2olVJ-2fF

Description: Post Script that can be run after completion of Veeam vCloud Director Cloud Connect Replication Job that automatically configures the NSX Edge to allow external network connectivity for replicas in the case of full failover.

Function: Using the Terraform vCloud Director Provider to automate NAT and Firewall rules for specific subnets and VM IP addresses for service access. Code can easily be expanded for configuration of additional Replica VMs and networking configuration.

* Firewall Rules for HTTP, HTTPS, SSH and ICMP for vOrg Network Subnet
* NAT Rules for inbound HTTP, HTTP, SSH to VM IP
* NAT rule for outbound access for vORG Network Subnet

Pre-Requisites: There are a few requirements and pre-requisites that need to be in place before adding the script to the Veeam Replication Job which launches the Terraform plan.

* Download Terraform executable and place into working folder
* vOrg Network needs to be previously created in vCloud Director on NSX Edge
* Reccomended to create a seperate vCloud Director Org user to action API calls

Variables: There are some variables that can be adjustment or need specifying.

All variables are in the terraform.tfvars file

    vcd_user = "apiuser"
    vcd_pass = "password"
    vcd_org = "ORG Name"
    vcd_url = "https://vcloud/api"
    vcd_vdc = "vCD Name"
    vcd_edge ="NSX Edge Name"
    vcd_external_ip="NSX Edge External IP"
    vcd_vm_1="Replica VM IP"
    vcd_vorg_network="vORG Network subnet and mask"

Usage:

Select ps1 script from Advanced Job settings in Veeam Replication Job: https://wp.me/p2olVJ-2fF

./terraform plan|apply|destory

eg. echo yes | ./terraform apply
