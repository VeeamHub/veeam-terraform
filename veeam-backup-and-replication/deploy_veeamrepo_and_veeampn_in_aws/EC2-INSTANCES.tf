resource "aws_instance" "VeeamPN" {
  ami = "${lookup(var.VeeamPNAMIImage, var.region)}"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.External.id}"
  vpc_security_group_ids = ["${aws_security_group.Main.id}"]
  source_dest_check = "false"
  key_name = "${var.key_name}"
  tags {
        Name = "VeeamPN"
  }
  provisioner "file" {
        source      = "configure.sh"
        destination = "/tmp/configure.sh"

        connection {
            type     = "ssh"
            user     = "ubuntu"
            # Enter in Private Key file name - should reside in same folder
            private_key = "${file("KEY.pem")}"
        }
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/configure.sh",
            "/tmp/configure.sh",
        ]
        connection {
            type     = "ssh"
            user     = "ubuntu"
            # Enter in Private Key file name - should reside in same folder
            private_key = "${file("KEY.pem")}"
        }

    }
}   

resource "aws_instance" "VeeamRepo" {
  ami = "${lookup(var.VeeamRepoAMIImage, var.region)}"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  subnet_id = "${aws_subnet.External.id}"
  vpc_security_group_ids = ["${aws_security_group.Main.id}"]
  source_dest_check = "false"
  root_block_device {
  volume_type = "gp2"
  # Set Volume to deisred size
  volume_size = 50
}
  key_name = "${var.key_name}"
  tags {
        Name = "VeeamRepo"
  }
provisioner "file" {
        source      = "configure2.sh"
        destination = "/tmp/configure2.sh"

        connection {
            type     = "ssh"
            user     = "centos"
            # Enter in Private Key file name - should reside in same folder
            private_key = "${file("KEY.pem")}"
        }
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/configure2.sh",
            "/tmp/configure2.sh",
        ]
        connection {
            type     = "ssh"
            user     = "centos"
            # Enter in Private Key file name - should reside in same folder
            private_key = "${file("KEY.pem")}"
        }

    }

}
