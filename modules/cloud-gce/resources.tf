locals {
  tags = {
    App       = "AlgoVPN"
    Workspace = terraform.workspace
    DeployID  = var.config.deploy_id
  }
  labels = { for k, v in local.tags : lower(k) => lower(v) }
  name   = "algo-${var.config.deploy_id}-${random_integer.seq.result}"
}

resource "random_integer" "seq" {
  min = 1
  max = 99
  keepers = {
    ipv6         = var.config.cloud.ipv6
    network_tier = var.config.cloud.network_tier
  }
}

resource "google_compute_network" "main" {
  name                    = local.name
  auto_create_subnetworks = false
  mtu                     = 1500
}

resource "google_compute_subnetwork" "main" {
  name             = local.name
  region           = var.config.cloud.region
  ip_cidr_range    = "172.16.254.0/23"
  network          = google_compute_network.main.id
  stack_type       = var.config.cloud.ipv6 ? "IPV4_IPV6" : "IPV4_ONLY"
  ipv6_access_type = var.config.cloud.ipv6 ? "EXTERNAL" : null
}

resource "google_compute_firewall" "ingress" {
  name          = "algo-${var.config.deploy_id}"
  description   = "Allow incoming connections to AlgoVPN instance"
  network       = google_compute_network.main.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [local.name]

  dynamic "allow" {
    for_each = [
      {
        "ports" : [22]
        "protocol" = "tcp"
      },
      {
        "ports" : [var.config.tfvars.wireguard.port]
        "protocol" = "udp"
      },
      {
        "ports" : []
        "protocol" = "icmp"
    }]

    content {
      ports    = allow.value.ports
      protocol = allow.value.protocol
    }
  }
}

resource "google_compute_address" "algo" {
  name         = local.name
  region       = var.config.cloud.region
  address_type = "EXTERNAL"
  network_tier = var.config.cloud.network_tier
}

data "google_compute_zones" "available" {
  region = var.config.cloud.region
}

resource "random_shuffle" "az" {
  input        = data.google_compute_zones.available.names
  result_count = 1
}

resource "google_compute_instance" "algo" {
  name                    = local.name
  description             = "AlgoVPN"
  machine_type            = var.config.cloud.size
  zone                    = random_shuffle.az.result[0]
  can_ip_forward          = true
  metadata_startup_script = var.config.user_data.script
  labels                  = local.labels
  tags                    = [local.name]

  boot_disk {
    auto_delete = true

    initialize_params {
      image = var.config.cloud.image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.main.name
    stack_type = var.config.cloud.ipv6 ? "IPV4_IPV6" : "IPV4_ONLY"

    access_config {
      nat_ip       = google_compute_address.algo.address
      network_tier = var.config.cloud.network_tier
    }

    dynamic "ipv6_access_config" {
      iterator = ipv6
      for_each = var.config.cloud.ipv6 ? ["PREMIUM"] : []

      content {
        network_tier = ipv6.value
      }
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.config.ssh_public_key}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
