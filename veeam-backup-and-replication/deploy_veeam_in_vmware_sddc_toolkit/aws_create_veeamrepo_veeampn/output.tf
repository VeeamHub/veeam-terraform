/*
Output Variables
*/
output "Public_IP_VeeamPN" {
  value = "${aws_instance.VeeamPN.public_ip}"
}

output "private_ip_VeeamPN" {
  value = "${aws_instance.VeeamPN.private_ip}"
}

output "private_ip_VeeamRepo" {
  value = "${aws_instance.VeeamRepo.private_ip}"
}