output "bastion-external-ELASTIC" {
  value = "${aws_instance.Bastion.public_ip}"
  description = "Public bastion server IP"
}

output "bastion-internal" {
  value = "${aws_instance.Bastion.private_ip}"
  description = "Private Bastion server IP"
}

output "NAT-external" {
  value = "${aws_instance.NAT.public_ip}"
  description = "Public NAT AZ1 IP"
}

output "NAT-internal" {
  value = "${aws_instance.NAT.private_ip}"
  description = "Private NAT AZ1 IP"
}

output "NAT-2-external" {
  value = "${aws_instance.NAT-2.public_ip}"
  description = "Public NAT AZ2 IP"
}

output "NAT-2-internal" {
  value = "${aws_instance.NAT-2.private_ip}"
  description = "Private NAT AZ2 IP"
}
