output "server_address" {
  value = "${digitalocean_droplet.algo.ipv4_address}"
}
