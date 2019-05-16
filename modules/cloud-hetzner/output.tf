output "server_id" {
  value = "${hcloud_server.main.id}"
}

output "ssh_user" {
  value = "root"
}
