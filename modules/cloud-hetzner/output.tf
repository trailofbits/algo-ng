output "server_id" {
  value = hcloud_server.main.id
}

output "server_address" {
  value = hcloud_floating_ip.main.ip_address
}

output "ssh_user" {
  value = "root"
}
