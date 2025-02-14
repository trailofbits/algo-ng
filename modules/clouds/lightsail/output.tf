output "resources" {
  value = {
    server_id = aws_lightsail_instance.main.id
    server_ip = aws_lightsail_static_ip.main.ip_address
    ssh_user  = "ubuntu"
    ipv6      = local.cloud_config.ipv6
  }
}
