output "ssh-bastion-public-ip" {
  value = "${aws_eip.bastion.public_ip}"
}
