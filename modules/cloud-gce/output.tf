output "server_address" {
  value = "${google_compute_address.main.address}"
}

output "server_id" {
  value = "${google_compute_instance.algo.instance_id}"
}

output "ssh_user" {
  value = "ubuntu"
}

output "ipv6" {
  value = "${var.ipv6}"
}
