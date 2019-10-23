
# vCenter FQDN or IP to which the systems will be deployed.
vsphere_server         = "VCENTER"

# vCenter Username with privileges to deploy machines
vsphere_user           = "administrator@vsphere.local"

# vCenter Password of User selected
vsphere_password       = "PASSWORD"

# vSphere Datacenter Name to which the systems will be deployed.
datacenter             = "VC03"

# vSphere Cluster or Resource Pool to which the systems will be deployed.
vsphere_resource_pool  = "TPM03-AS"

# vSphere Virtual Machine Network to which the systems will be attached.
vsphere_network_name   = "TPM03-730"

# vSphere Full Template Path from which the systems will be deployed.  Must include any vSphere folder names e.g Templates/windows_2016
veeam_template_path    = "TPM03-AS/TPM03-WIN2016-TEMPLATE"

# Total number of vCPUs to assign to Veeam VBR Server
vbr_cpu_count          =  2

# Total amount of memory (MB) to assign to Veeam VBR Server
vbr_memory_size_mb     = 8192

# [Optional] vSphere Full Template Path from which the Proxy systems will be deployed.  If empty or 'same' then the variable veeam_template_path will be used.
proxy_template_path    = "same"

# Total number of vCPUs to assign to Veeam Proxy Server
proxy_cpu_count        = 2

# Total amount of memory (MB) to assign to Veeam Proxy Server
proxy_memory_size_mb   = 4096

# Should the Veeam Proxy Server be registered to the Veeam VBR Server.
# If false then the proxy server will not register.  This is handy for creating fast launch templates.
should_register_proxy  = true

# vSphere Folder to which the systems will be deployed.  Must exist prior to execution.
veeam_deployment_folder= "TPM03-AS"

# Username for Remote Windows Management Connections.  Must be in Domain\\username or username (for local accounts) format.
vbr_admin_user             = "USERNAME"

# Password for Remote Windows Management Connections
vbr_admin_password         = "PASSWORD"

# Username for Remote Windows Management Connections.  Must be in Domain\\username or username (for local accounts) format.
proxy_admin_user       = "USERNAME"

# Password for Remote Windows Management Connections
proxy_admin_password   = "PASSWORD"

# FQDN domain name
domain_name            = "aperaturelabs.biz"

# Enter the hostname to give to the Veeam Backup and Replication Server.  Should be less than 16 characters.
veeam_server_name      = "SDDC-VBR-01"

# Enter the hostname prefix to give to the Veeam Proxy Server.  Must be less than 12 characters as proxies will receive a 3 digit identifier at the end of their name.
veeam_proxy_name       = "SDDC-VPR-01"

# Number of Proxy Servers to create.  Zero will remove all proxies created by this Terraform State.
proxy_count            = 0


# Chef Configuration

# Full URL from which the Veeam software will be downloaded.
veeam_installation_url = "https://download.veeam.com/VeeamBackup&Replication_9.5.0.1922.Update3a.iso"

# SHA256 Checksum for the ISO Url selected.
veeam_installation_checksum = "8a594cec74059f9929ea765ac5e70a49da6fc93803b567cbb9d74fbb1a49a6cc"

# Veeam License File.
license_base64_encoded = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPExpY2Vuc2VzPjxMaWNlbnNlPjwhW0NEQVRBW0Nsb3VkIENvbm5lY3Q9Tm8KRGVzY3JpcHRpb249Q29weXJpZ2h0IDIwMTkgVmVlYW0sIEluYy4gQWxsIFJpZ2h0cyBSZXNlcnZlZC4gVGhlIFNvZnR3YXJlIFByb2R1Y3QgaXMgcHJvdGVjdGVkIGJ5IGNvcHlyaWdodCBhbmQgb3RoZXIgaW50ZWxsZWN0dWFsIHByb3BlcnR5IGxhd3MgYW5kIHRyZWF0aWVzLiBWZWVhbSBvciBpdHMgc3VwcGxpZXJzIG93biB0aGUgdGl0bGUsIGNvcHlyaWdodCwgYW5kIG90aGVyIGludGVsbGVjdHVhbCBwcm9wZXJ0eSByaWdodHMgaW4gdGhlIFNvZnR3YXJlIFByb2R1Y3QuIFZlZWFtIHJlc2VydmVzIGFsbCByaWdodHMgbm90IGV4cHJlc3NseSBncmFudGVkIHRvIHlvdSBpbiBFVUxBLiBUaGUgU29mdHdhcmUgUHJvZHVjdCBpcyBsaWNlbnNlZCwgbm90IHNvbGQuIFZlZWFtIGdyYW50cyB0byB5b3UgYSBub25leGNsdXNpdmUgbm9udHJhbnNmZXJhYmxlIGxpY2Vuc2UgdG8gdXNlIHRoZSBTb2Z0d2FyZSBQcm9kdWN0LCBwcm92aWRlZCB0aGF0IHlvdSBhZ3JlZSB3aXRoIEVVTEEuCkVkaXRpb249RW50ZXJwcmlzZSBQbHVzCkV4cGlyYXRpb24gZGF0ZT0wNy8wNC8yMDE5Ckluc3RhbmNlcz0xMDAwCkxpY2Vuc2UgYWRtaW5pc3RyYXRvciBlLW1haWw9YW50aG9ueS5zcGl0ZXJpQHZlZWFtLmNvbQpMaWNlbnNlIHR5cGU9RXZhbHVhdGlvbgpMaWNlbnNlZSBjb21wYW55PVZlZWFtIFNvZnR3YXJlIC0gQWN0aXZpdGllcyBUcmFja2luZwpMaWNlbnNlZSBlLW1haWw9YW50aG9ueS5zcGl0ZXJpQHZlZWFtLmNvbQpMaWNlbnNlZSBmaXJzdCBuYW1lPVZlZWFtIFNEREMKTGljZW5zZWUgbGFzdCBuYW1lPVRvb2xraXQKTW9uaXRvcmluZz1ZZXMKU3VwcG9ydCBleHBpcmF0aW9uIGRhdGU9MDcvMDQvMjAxOQpTaWduYXR1cmU9NThDQ0FCQkY1RjkxNjdEQUEyODI4N0EwODhCOUM5MTVDMUI5OThCQjEyNTYxNzg1NzEwQjExMzU1MzRFMTk3Mjk4RkM3QTQ2RjgyOENCRTkwQTVFMzA5OUM5M0FBM0E1QTlFMEM3NjYyNjE1MjVGNDcwNjA4MzcyMDQ3NjVFOTg3REQ3M0IxRUIwMjA4Nzk5NEY0NDUxMkExOEJGMEMyNzRCM0M4RTA4Njk1MzhBRjBEMkJDRTkyOEI5RjE0MjQ5QTRBNDI0OUI4QkM5MjRFNkZERjREQkUyREI0RTJDRjc3NkRFMkNBNkM1MkY3M0IxNUVGRDc2RDQyQUExQjc5OApdXT48L0xpY2Vuc2U+PC9MaWNlbnNlcz4="
veeam_installation_checksum = "9a6fa7d857396c058b2e65f20968de56f96bc293e0e8fd9f1a848c7d71534134"






