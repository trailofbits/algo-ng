output "server_address" {
  value = "${digitalocean_floating_ip.algo.ip_address}"
}

output "server_id" {
  value = "${digitalocean_droplet.algo.id}"
}

output "ssh_user" {
  value = "root"
}

output "ipv6" {
  value = "${var.ipv6}"
}
