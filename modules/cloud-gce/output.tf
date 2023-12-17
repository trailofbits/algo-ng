output "server_id" {
  value = google_compute_instance.algo.id
}

output "server_address" {
  value = google_compute_address.algo.address
}

output "ssh_user" {
  value = "ubuntu"
}
