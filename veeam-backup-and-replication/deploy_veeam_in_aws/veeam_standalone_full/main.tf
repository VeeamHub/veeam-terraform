# Configure the VMware vSphere Provider
provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"

  # if you have a self-signed cert
  allow_unverified_ssl = true
}

# Data resources will discover information about the vSphere environment to be used in other Resources.
data "vsphere_datacenter" "dc" {
  name = "${var.datacenter}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.vsphere_resource_pool}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.vsphere_network_name}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.veeam_template_path}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "proxy_template" {
  name          = "${
    var.proxy_template_path != ""
    ?
      var.proxy_template_path != "same"
      ?
        var.proxy_template_path
      :
        var.veeam_template_path
    :
      var.veeam_template_path
    }"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

