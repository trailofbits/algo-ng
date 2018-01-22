resource "google_compute_network" "algo" {
  name                    = "algo-${var.region}-${var.algo_name}"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "algo_ingress" {
  name        = "algo-${var.region}-${var.algo_name}-ingress"
  network     = "${google_compute_network.algo.name}"

  allow {
    protocol = "udp"
    ports    = [
      "500",
      "4500"
    ]
  }

  allow {
    protocol = "tcp"
    ports    = [ "22" ]
  }

  allow { protocol = "icmp" }

}

resource "google_compute_firewall" "algo_egress" {
  name        = "algo-${var.region}-${var.algo_name}-egress"
  network     = "${google_compute_network.algo.name}"
  direction   = "EGRESS"
  allow { protocol = "all" }
}

resource "google_compute_instance" "algo" {
  name          = "algo-${var.region}-${var.algo_name}"
  machine_type  = "${var.size}"
  zone          = "${var.region}"
  tags          = [ "environment-algo" ]
  can_ip_forward = true


  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }

  network_interface {
    network = "${google_compute_network.algo.name}"
      access_config {}
  }

  metadata {
    sshKeys = "ubuntu:${var.public_key_openssh}"
  }

}
