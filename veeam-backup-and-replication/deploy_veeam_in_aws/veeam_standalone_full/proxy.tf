# Terraform template for Veeam Proxy Servers
#
# Maintained by Exposphere Data, LLC
# Version 1.0.0
# Date 2018-08-14
#
# This template will deploy one or more Windows Templates to create Veeam Proxy Servers
#

resource "vsphere_virtual_machine" "proxy" {
  count            = "${var.proxy_count}"
  name             = "${format("${var.veeam_proxy_name}%02d", count.index+1)}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  folder           = "${var.veeam_deployment_folder}"
  guest_id         = "${data.vsphere_virtual_machine.proxy_template.guest_id}"

  scsi_type        = "${data.vsphere_virtual_machine.proxy_template.scsi_type}"

  num_cpus         = "${var.proxy_cpu_count}"
  memory           = "${var.proxy_memory_size_mb}"

  network_interface {
    network_id     = "${data.vsphere_network.network.id}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.proxy_template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.proxy_template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.proxy_template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.proxy_template.id}"

    customize {
      network_interface {}
      windows_options {
        computer_name  = "${format("${var.veeam_proxy_name}%02d", count.index+1)}"
      }
    }

  }
}
resource "null_resource" "install_chef_proxy" {
  count            = "${var.proxy_count}"
  triggers {
    instance_id = "${vsphere_virtual_machine.proxy.*.id[count.index]}"
  }

  depends_on = [
    "vsphere_virtual_machine.proxy"
  ]

  connection {
    host      = "${element(vsphere_virtual_machine.proxy.*.guest_ip_addresses.0, count.index)}"
    type      = "winrm"
    user      = "${var.proxy_admin_user}"
    password  = "${var.proxy_admin_password}"
    timeout   = "20m"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe -Command \". { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install\""
    ]
  }

  # =>
  # => Execute the following upon destruction
  # =>
  provisioner "file" {
    when        = "destroy"
    source      = "${path.module}/scripts/prep_host.ps1"
    destination = "C:\\tmp\\prep_host.ps1"
  }

  provisioner "remote-exec" {
    when        = "destroy"
    inline = [
      "powershell.exe -File \"C:\\tmp\\prep_host.ps1\""
    ]
  }

  provisioner "remote-exec" {
    when        = "destroy"
    inline = [
      "powershell.exe -Command \"Remove-Item -Confirm:$False C:\\tmp\\prep_host.ps1\""
    ]
  }

  provisioner "file" {
    when        = "destroy"
    source      = "${path.module}/files/Berksfile"
    destination = "C:\\tmp\\chef_cookbooks\\Berksfile"
  }
  provisioner "file" {
    when        = "destroy"
    source      = "${path.module}/files/solo.rb"
    destination = "C:\\tmp\\chef\\solo.rb"
  }
  provisioner "file" {
    when        = "destroy"
    content     = <<-EOF
      {
        "veeam": {
          "installer": {
            "package_url": "${var.veeam_installation_url}",
            "package_checksum": "${var.veeam_installation_checksum}"
          },
          "version": "9.5",
          "console": {
            "accept_eula": true,
            "keep_media": true
          },
          "proxy": {
            "vbr_server": "${vsphere_virtual_machine.vbr_server.default_ip_address}",
            "vbr_username": "${var.vbr_admin_user}",
            "vbr_password": "${var.vbr_admin_password}",
            "proxy_username": "${var.proxy_admin_user}",
            "proxy_password": "${var.proxy_admin_password}",
            "use_ip_address": true,
            "register": ${var.should_register_proxy == "true" ? true : false}
          }
        },
        "run_list": [
          "recipe[veeam::proxy_remove]"
        ]
      }
    EOF
    destination = "C:\\tmp\\chef\\dna.json"
  }
  provisioner "file" {
    when        = "destroy"
    source      = "${path.module}/scripts/bootstrap.ps1"
    destination = "C:\\tmp\\chef-bootstrap.ps1"
  }

  # =>
  # => Execute Bootstrap script to apply CHEF configuration and setup.
  # =>
  provisioner "remote-exec" {
    when        = "destroy"
    inline = [
      "powershell.exe -Command \"C:\\tmp\\chef-bootstrap.ps1\""
    ]
  }
}

resource "null_resource" "bootstrap_proxy" {
  count            = "${var.proxy_count}"
  triggers {
    instance_id = "${vsphere_virtual_machine.proxy.*.id[count.index]}",
    should_register_proxy = "${var.should_register_proxy}"
  }

  depends_on = [
    "null_resource.install_chef_proxy",
    "null_resource.bootstrap_vbr_server"
  ]

  connection {
    host      = "${element(vsphere_virtual_machine.proxy.*.guest_ip_addresses.0, count.index)}"
    type      = "winrm"
    user      = "${var.proxy_admin_user}"
    password  = "${var.proxy_admin_password}"
    timeout   = "20m"
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
          "console": {
            "accept_eula": true,
            "keep_media": true
          },
          "proxy": {
            "vbr_server": "${vsphere_virtual_machine.vbr_server.default_ip_address}",
            "vbr_username": "${var.vbr_admin_user}",
            "vbr_password": "${var.vbr_admin_password}",
            "proxy_username": "${var.proxy_admin_user}",
            "proxy_password": "${var.proxy_admin_password}",
            "use_ip_address": true,
            "register": ${var.should_register_proxy == "true" ? true : false}
          }
        },
        "run_list": [
          "recipe[veeam::proxy_server]"
        ]
      }
    EOF
    destination = "C:\\tmp\\chef\\dna.json"
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
