output "server_id" {
  value = digitalocean_droplet.main.id
}

output "ssh_user" {
  value = "root"
}
