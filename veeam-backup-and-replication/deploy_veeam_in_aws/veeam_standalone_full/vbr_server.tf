# Terraform template for Veeam VBR Server
#
# Maintained by Exposphere Data, LLC
# Version 1.0.0
# Date 2018-08-14
#
# This template will deploy a Windows Template to create Veeam VBR Server
#

resource "vsphere_virtual_machine" "vbr_server" {
  name             = "${var.veeam_server_name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder           = "${var.veeam_deployment_folder}"
  guest_id         = "${data.vsphere_virtual_machine.template.guest_id}"

  scsi_type        = "${data.vsphere_virtual_machine.template.scsi_type}"

  num_cpus = "${var.vbr_cpu_count}"
  memory   = "${var.vbr_memory_size_mb}"

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      network_interface {
        ipv4_address = "10.0.30.117"
        ipv4_netmask = 24
      }
        ipv4_gateway = "10.0.30.1"
        dns_server_list = ["10.0.0.2", "1.1.1.1"]
      windows_options {
        computer_name  = "${var.veeam_server_name}"
      }
    }
  }
}

# Install the Chef Client and configure the initial connection to the Chef Organization.
# Note: On destroy, this client will
resource "null_resource" "install_chef_vbr_server" {
  triggers {
    instance_id = "${vsphere_virtual_machine.vbr_server.id}"
  }

  depends_on = [
    "vsphere_virtual_machine.vbr_server"
  ]

  connection {
    host      = "${vsphere_virtual_machine.vbr_server.guest_ip_addresses.0}"
    type      = "winrm"
    user      = "${var.vbr_admin_user}"
    password  = "${var.vbr_admin_password}"
    timeout   = "20m"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe -Command \". { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install\""
    ]
  }
}

resource "null_resource" "bootstrap_vbr_server" {
  triggers {
    instance_id = "${vsphere_virtual_machine.vbr_server.id}"
  }

  depends_on = [
    "null_resource.install_chef_vbr_server"
  ]

  connection {
    host      = "${vsphere_virtual_machine.vbr_server.guest_ip_addresses.0}"
    type      = "winrm"
    user      = "${var.vbr_admin_user}"
    password  = "${var.vbr_admin_password}"
    timeout   = "20m"
  }

    provisioner "remote-exec" {
    inline = [
        "route add -p 10.0.100.0 MASK 255.255.255.0 10.0.30.254"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/scripts/prep_host.ps1"
    destination = "C:\\tmp\\prep_host.ps1"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe -File \"C:\\tmp\\prep_host.ps1\""
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe -Command \"Remove-Item -Confirm:$False C:\\tmp\\prep_host.ps1\""
    ]
  }

  provisioner "file" {
    source      = "${path.module}/files/Berksfile"
    destination = "C:\\tmp\\chef_cookbooks\\Berksfile"
  }
  provisioner "file" {
    source      = "${path.module}/files/solo.rb"
    destination = "C:\\tmp\\chef\\solo.rb"
  }
  provisioner "file" {
    content     = <<-EOF
      {
        "veeam": {
          "installer": {
            "package_url": "${var.veeam_installation_url}",
            "package_checksum": "${var.veeam_installation_checksum}"
          },
          "version": "9.5",
          "server": {
            "accept_eula": true,
            "keep_media": true,
            "evaluation": false
          },
          "console": {
            "accept_eula": true
          },
          "host": {
            "vbr_server": "${vsphere_virtual_machine.vbr_server.default_ip_address}",
            "vbr_username": "${var.vbr_admin_user}",
            "vbr_password": "${var.vbr_admin_password}",
            "host_username": "${var.vsphere_user}",
            "host_password": "${var.vsphere_password}",
            "type": "vmware",
            "server": "${var.vsphere_server}"
          }
        },
        "run_list": [
          "recipe[veeam::standalone_complete]"
        ]
      }
    EOF
    destination = "C:\\tmp\\chef\\dna.json"
  }
provisioner "file" {
  source = "license.json"
  destination = "C:\\tmp\\chef\\data_bags\\veeam\\license.json"
}

  provisioner "file" {
    source      = "${path.module}/scripts/bootstrap.ps1"
    destination = "C:\\tmp\\chef-bootstrap.ps1"
  }

  # =>
  # => Execute Bootstrap script to apply CHEF configuration and setup.
  # =>
  provisioner "remote-exec" {
    inline = [
      "powershell.exe -File \"C:\\tmp\\chef-bootstrap.ps1\""
    ]
  }
}
