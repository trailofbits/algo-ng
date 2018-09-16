output "server_address" {
  value = "${aws_eip.main.public_ip}"
}

output "server_id" {
  value = "${aws_instance.main.id}"
}

output "ssh_user" {
  value = "ubuntu"
}

output "ipv6" {
  value = "${var.ipv6}"
}
