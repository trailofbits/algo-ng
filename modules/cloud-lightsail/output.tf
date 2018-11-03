output "server_address" {
  value = "${aws_lightsail_static_ip.main.ip_address}"
}

output "server_id" {
  value = "${aws_lightsail_instance.main.id}"
}

output "ssh_user" {
  value = "ubuntu"
}

output "ipv6" {
  value = "${var.ipv6}"
}
