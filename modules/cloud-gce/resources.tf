resource "random_id" "name" {
  byte_length = 8

  keepers {
    ami_id = "${var.region}/${var.algo_name}"
  }
}

locals {
  name = "algovpn-${random_id.name.hex}"
}

resource "google_compute_network" "main" {
  name                    = "${local.name}"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "ingress" {
  name    = "${local.name}"
  network = "${google_compute_network.main.name}"

  allow {
    protocol = "udp"

    ports = [
      "500",
      "4500",
      "${var.wireguard_network["port"]}",
    ]
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_address" "main" {
  name         = "${local.name}"
  region       = "${element(split("-", var.region), 0)}-${element(split("-", var.region), 1)}"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "algo" {
  name           = "${var.algo_name}"
  machine_type   = "${var.size}"
  zone           = "${var.region}"
  can_ip_forward = true

  boot_disk {
    auto_delete = true

    initialize_params {
      image = "${var.image}"
    }
  }

  network_interface {
    network = "${google_compute_network.main.name}"

    access_config {
      nat_ip = "${google_compute_address.main.address}"
    }
  }

  metadata {
    sshKeys   = "ubuntu:${var.public_key_openssh}"
    user-data = "${var.user_data}"
  }

  labels {
    "environment" = "algo"
  }

  lifecycle {
    create_before_destroy = true
  }
}
