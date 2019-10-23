# Basic Deployment of Veeam on VMware
This set of templates will deploy Veeam Backup and Replication server in a complete deployment along with an optional number of Veeam VMware Proxies on VMware using Chef-Solo mode with the Chef Client.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Terraform Variable Declarations](#terraform-variable-declarations)
  - [VMware Variables](#vmware-variables)
  - [Veeam Server Variables](#veeam-server-variables)
  - [Chef Server Variables](#chef-server-variables)
- [Veeam Backup and Replication ISO](#veeam-backup-and-replication-iso)
- [Terraform Execution Commands](#terraform-execution-commands)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Requirements

- [Terraform 0.11.8+](https://www.terraform.io/downloads.html)
- Chef Client 12+
- Windows 2012R2 or Windows 2016 VMware Template
- vSphere Credentials

## Getting Started
The Terraform templates included in this repository requires Terraform to be available locally on the machine running the templates.  Before you begin, please verify that you have the following information:

1. Download [Terraform](https://www.terraform.io/downloads.html) (minimum tested version 0.11.8) binary to your workstation.
2. Gather the VMware credentials required to communicate to vCenter
3. Find the VMware template name to use and the VMware folder to which the machines would be deployed.
4. Save a copy of the file `terraform.tfvars.example` as `terraform.tfvars`
5. Update the variable values in the newly created `terraform.tfvars` file.
6. Run `terraform init` to install the required plugins and modules
7. Test the variables and templates by running `terraform plan`
8. If everything looks good, then create the environment by running `terraform apply`

[More information on optional Terraform Configurations](#terraform-execution-commands)

## Terraform Variable Declarations

### VMware Variables

| Name | Type | Description | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| `vsphere_server` | String | vCenter FQDN or IP to which the systems will be deployed. | | X |
| `vsphere_user` | String | vCenter Username with privileges to deploy machines | | X |
| `vsphere_password` | String | vCenter Password of User selected | | X |
| `datacenter` | String | vSphere Datacenter Name to which the systems will be deployed. | | X |
| `vsphere_resource_pool` | String | vSphere Cluster or Resource Pool to which the systems will be deployed. | | X |
| `vsphere_network_name` | String | vSphere Virtual Machine Network to which the systems will be attached. | | X |
| `veeam_template_path` | String | vSphere Full Template Path from which the systems will be deployed.  Must include any vSphere folder names e.g Templates/windows_2016 | | X |

### Veeam Server Variables

| Name | Type | Description | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| `vbr_cpu_count` | String | Total number of vCPUs to assign to Veeam VBR Server | 2 | X |
| `vbr_memory_size_mb` | String | Total amount of memory (MB) to assign to Veeam VBR Server | 4096 | X |
| `proxy_template_path` | String | Optional] vSphere Full Template Path from which the Proxy systems will be deployed.  If empty or 'same' then the variable veeam_template_path will be used. | "same" | X |
| `proxy_cpu_count` | String | Total number of vCPUs to assign to Veeam Proxy Server | 2 | X |
| `proxy_memory_size_mb` | String | Total amount of memory (MB) to assign to Veeam Proxy Server. | 2048 | X |
| `should_register_proxy` | String | Should the Veeam Proxy Server be registered to the Veeam VBR Server. | "true" | X |
| `veeam_deployment_folder` | String | vSphere Folder to which the systems will be deployed.  Must exist prior to execution. | | X |
| `admin_user` | String | Username for Remote Windows Management Connections.  Must be in Domain\\username or .\\username format. | | X |
| `admin_password` | String | Password for Remote Windows Management Connections | | X |
| `proxy_admin_user` | String | Username for Remote Windows Management Connections.  Must be in Domain\\username or .\\username format. | | X |
| `proxy_admin_password` | String | Password for Remote Windows Management Connections | | X |
| `domain_name` | String | FQDN domain name | | X |
| `veeam_server_name` | String | Enter the hostname to give to the Veeam Backup and Replication Server.  Should be less than 16 characters. | "veeam" | X |
| `veeam_proxy_name` | String | Enter the hostname prefix to give to the Veeam Proxy Server.  Must be less than 12 characters as proxies will receive a 3 digit identifier at the end of their name. | "proxy" | X |
| `proxy_count` | String | Number of Proxy Servers to create.  Zero will remove all proxies created by this Terraform State | 0 | X |

### Chef Server Variables

| Name | Type | Description | Default Value | Mandatory |
| --- | --- | --- | --- | --- |
| `veeam_installation_url` | String | Full URL from which the Veeam software will be downloaded. | [VeeamBackup&Replication_9.5.0.1922.Update3a.iso](https://download.veeam.com/VeeamBackup&Replication_9.5.0.1922.Update3a.iso) | X |
| `veeam_installation_checksum` | String | SHA256 Checksum for the ISO Url selected. | 9a6fa7d857396c058b2e65f20968de56f96bc293e0e8fd9f1a848c7d71534134 | X |


## Veeam Backup and Replication ISO
The attribute `node['veeam']['version']` is used to evaluate the ISO download path and checksum for the installation media.  When provided, the version selected will be downloaded based on the value found in `libraries/helper.rb`.  This media path can be overridden by providing the appropriate installation media attributes - `node['veeam']['installer']['package_url']` and `node['veeam']['installer']['package_checksum']`.  By default, these attributes are `nil` and the system will download the ISO every time.

| Version | ISO URL | SHA256 |
| ------------- |-------------|-------------|
| **9.5** | [VeeamBackup&Replication_9.5.0.711.iso](http://download.veeam.com/VeeamBackup&Replication_9.5.0.711.iso) | af3e3f6db9cb4a711256443894e6fb56da35d48c0b2c32d051960c52c5bc2f00 |
| **9.5.0.711** | [VeeamBackup&Replication_9.5.0.711.iso](http://download.veeam.com/VeeamBackup&Replication_9.5.0.711.iso) | af3e3f6db9cb4a711256443894e6fb56da35d48c0b2c32d051960c52c5bc2f00 |
| **9.5.0.1038** | [VeeamBackup&Replication_9.5.0.1038.Update2.iso](http://download.veeam.com/VeeamBackup&Replication_9.5.0.1038.Update2.iso) | 180b142c1092c89001ba840fc97158cc9d3a37d6c7b25c93a311115b33454977 |
| **9.5.0.1536** | [VeeamBackup&Replication_9.5.0.1536.Update3.iso](http://download.veeam.com/VeeamBackup&Replication_9.5.0.1536.Update3.iso) | 5020ef015e4d9ff7070d43cf477511a2b562d8044975552fd08f82bdcf556a43 |
| **9.5.0.1922** | [VeeamBackup&Replication_9.5.0.1922.Update3a.iso](https://download.veeam.com/VeeamBackup&Replication_9.5.0.1922.Update3a.iso) | 9a6fa7d857396c058b2e65f20968de56f96bc293e0e8fd9f1a848c7d71534134 |

## Terraform Execution Commands
Below is a list of different command options when executing Terraform.

| Command | Description | Result |
| --- | --- | --- |
| `terraform init` | Downloads all of the required plugins for Terraform to execute these templates. | Creates a .terraform directory in the location of the templates and pulls the current plugin versions. |
| `terraform plan` | Runs validation checks against the Terraform templates and variables. | When run, it will display a list of changed items and what will be created or updated. |
| `terraform apply` | Applies the Terraform templates to create the infrastructure needed to satisfy the configuration. If the `-auto-approve` switch is added, then it will bypass the *Should proceed?* question. | By default, will create only a new Veeam Backup and Replication server unless the `terraform.tfvars` file has the variable `proxy_count` set to a value greater than 0. |
| `terraform apply -var proxy_count=2` | Applies the Terraform templates to create the infrastructure needed to satisfy the configuration and overrides the value for the variable `proxy_count`. | Variable values are selected by first the default value in `variables.tf`, second the value in the `terraform.tfvars` file, and third the command line value provided. In this case, we are overriding the number of proxy servers to create.  If previous executions set the value of `proxy_count` to 3, then this command would remove the last proxy server and leave only two proxy hosts. |
| `terraform destroy` | Reverses the entire configuration and destroys the infrastructure. If the `-force` switch is added, then it will bypass the *Should proceed?* question. | **WARNING**: This will delete everything in your environment based on the templates.  If you only want to remove the proxies, then you can simply set the `proxy_count` variable as mentioned previously. |
| `terraform apply -var proxy_count=1 -var should_register_proxy=false` | This command will build the Veeam VBR server and deploy one Proxy Server but not register the proxy to VBR. | This command is handy for staging a new Proxy Server template.  By deploying in this manner:<ol><li>you can prestage the installation of the Veeam components</li><li>shutdown the machine</li><li>clone to a new template</li><li>then power on the proxy server</li><li>finally, run the process again using `terraform apply -var proxy_count=0` to delete the proxy cleanly</li></ol>|

## License and Author

_Note: This repository is not officially supported by or released by Veeam Software, Inc._

- Author:: Exosphere Data, LLC ([chef@exospheredata.com](mailto:chef@exospheredata.com))

```text
Copyright 2018 Exosphere Data, LLC
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
except in compliance with the License. You may obtain a copy of the License at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the
License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
either express or implied. See the License for the specific language governing permissions
and limitations under the License.
```



