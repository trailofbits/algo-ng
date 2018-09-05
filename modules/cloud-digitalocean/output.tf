output "server_address" {
  value = "${digitalocean_floating_ip.algo.ip_address}"
}

output "droplet_id" {
  value = "${digitalocean_droplet.algo.id}"
}
