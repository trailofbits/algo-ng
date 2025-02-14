output "resources" {
  value = {
    server_id = digitalocean_droplet.main.id
    server_ip = digitalocean_floating_ip.main.ip_address
    ssh_user  = "root"
    ipv6      = local.cloud_config.ipv6
  }
}
