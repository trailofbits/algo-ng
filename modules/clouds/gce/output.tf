output "resources" {
  value = {
    server_id = google_compute_instance.algo.id
    server_ip = google_compute_address.algo.address
    ssh_user  = "ubuntu"
    ipv6      = local.cloud_config.ipv6
  }
}
