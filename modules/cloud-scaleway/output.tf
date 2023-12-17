output "server_id" {
  value = scaleway_instance_server.main.id
}

output "server_address" {
  value = scaleway_instance_ip.main.address
}

output "ssh_user" {
  value = "root"
}
