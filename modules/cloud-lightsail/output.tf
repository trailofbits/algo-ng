output "server_id" {
  value = aws_lightsail_instance.main.id
}

output "server_address" {
  value = aws_lightsail_static_ip.main.ip_address
}

output "ssh_user" {
  value = "ubuntu"
}
