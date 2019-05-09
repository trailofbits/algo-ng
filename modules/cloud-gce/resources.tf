resource "random_id" "name" {
  byte_length = 3

  keepers = {
    region_name = "${var.region}/${var.algo_name}"
    user_data   = "${var.user_data}"
  }
}

locals {
  name = "${var.algo_name}-${random_id.name.hex}"
}

resource "google_compute_network" "main" {
  name                    = "${local.name}"
  description             = "${var.algo_name}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "${local.name}"
  ip_cidr_range = "10.2.0.0/16"
  network       = "${google_compute_network.main.self_link}"
}

resource "google_compute_firewall" "ingress" {
  name        = "${local.name}"
  description = "${var.algo_name}"
  network     = "${google_compute_network.main.name}"

  dynamic "allow" {
    for_each = [
      ":icmp",
      "22:tcp",
      "500,4500,${var.wireguard_network["port"]}:udp"
    ]

    content {
      ports = [
        for i in split(",", split(":", allow.value)[0]) :
        i
        if length(i) > 0
      ]
      protocol = split(":", allow.value)[1]
    }
  }
}

data "google_compute_zones" "available" {}

resource "random_shuffle" "az" {
  input        = data.google_compute_zones.available.names
  result_count = 1
}

resource "google_compute_instance" "algo" {
  name           = "${var.algo_name}"
  description    = "${var.algo_name}"
  machine_type   = "${var.size}"
  zone           = "${random_shuffle.az.result[0]}"
  can_ip_forward = true

  boot_disk {
    auto_delete = true

    initialize_params {
      image = "${var.image}"
    }
  }

  network_interface {
    network    = "${google_compute_network.main.name}"
    subnetwork = "${google_compute_subnetwork.main.name}"

    access_config {
      nat_ip = "${var.server_address}"
    }
  }

  metadata = {
    sshKeys   = "ubuntu:${var.public_key_openssh}"
    user-data = "${var.user_data}"
  }

  labels = {
    "environment" = "algo"
  }

  lifecycle {
    create_before_destroy = true
  }
}
