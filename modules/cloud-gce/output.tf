output "server_id" {
  value = "${google_compute_instance.algo.instance_id}"
}

output "ssh_user" {
  value = "ubuntu"
}
