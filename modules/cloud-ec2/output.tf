output "server_address" {
  value = "${aws_eip.main.public_ip}"
}

output "instance_id" {
  value = "${aws_instance.main.id}"
}
