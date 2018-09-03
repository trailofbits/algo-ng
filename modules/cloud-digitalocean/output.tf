output "server_address" {
  value = "${digitalocean_floating_ip.algo.ip_address}"
}
