output "resources" {
  value = {
    server_id = aws_instance.main.id
    server_ip = aws_eip.main.public_ip
    ssh_user  = "ubuntu"
    ipv6      = local.cloud_config.ipv6
  }
}
