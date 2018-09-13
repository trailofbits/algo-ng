resource "random_id" "name" {
  byte_length = 8
  keepers {
    ami_id = "${var.region}/${var.algo_name}"
  }
}

resource "google_compute_network" "main" {
  name                    = "algovpn-${random_id.name.hex}"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "ingress" {
  name    = "algovpn-${random_id.name.hex}"
  network = "${google_compute_network.main.name}"

  allow {
    protocol = "udp"
    ports    = [
      "500",
      "4500"
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
  name         = "algovpn-${random_id.name.hex}"
  region       = "${element(split("-", var.region), 0)}-${element(split("-", var.region), 1)}"
  address_type = "EXTERNAL"
}

resource "google_compute_instance" "algo" {
  name                    = "${var.algo_name}"
  machine_type            = "${var.size}"
  zone                    = "${var.region}"
  metadata_startup_script = "${var.user_data}"
  can_ip_forward          = true

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
}
