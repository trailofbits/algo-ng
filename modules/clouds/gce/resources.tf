locals {
  tags = {
    App       = "AlgoVPN"
    Workspace = terraform.workspace
    DeployID  = var.deploy_id
  }

  labels       = { for k, v in local.tags : lower(k) => lower(v) }
  name         = "algo-vpn-${var.deploy_id}"
  cloud_config = var.algo_config.clouds.gce

  wireguard_ports = [{
    "ports" : [var.algo_config.wireguard.port],
    "protocol" = "udp"
  }]

  ipsec_ports = [{
    "ports" : [500],
    "protocol" = "udp"
    },
    {
      "ports" : [4500],
      "protocol" = "udp"
  }]

  vpn_ports = concat(
    var.algo_config.wireguard.enabled ? local.wireguard_ports : [],
    var.algo_config.ipsec.enabled ? local.ipsec_ports : [],
  )
}

resource "google_compute_network" "main" {
  name                    = local.name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name             = local.name
  region           = local.cloud_config.region
  ip_cidr_range    = "172.16.254.0/23"
  network          = google_compute_network.main.id
  stack_type       = local.cloud_config.ipv6 ? "IPV4_IPV6" : "IPV4_ONLY"
  ipv6_access_type = local.cloud_config.ipv6 ? "EXTERNAL" : null
}

resource "google_compute_firewall" "ingress" {
  name          = local.name
  description   = "Allow incoming connections to AlgoVPN instance"
  network       = google_compute_network.main.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [local.name]

  dynamic "allow" {
    for_each = concat([
      {
        "ports" : [22]
        "protocol" = "tcp"
      },
      {
        "ports" : []
        "protocol" = "icmp"
      }
    ], local.vpn_ports)

    content {
      ports    = allow.value.ports
      protocol = allow.value.protocol
    }
  }
}

resource "google_compute_address" "algo" {
  name         = local.name
  region       = local.cloud_config.region
  address_type = "EXTERNAL"
  network_tier = "STANDARD"
}

data "google_compute_zones" "available" {
  region = local.cloud_config.region
}

resource "random_shuffle" "az" {
  input        = data.google_compute_zones.available.names
  result_count = 1
}

data "google_compute_image" "ubuntu" {
  family  = local.cloud_config.image
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "algo" {
  name                    = local.name
  machine_type            = local.cloud_config.size
  zone                    = random_shuffle.az.result[0]
  can_ip_forward          = true
  metadata_startup_script = var.user_data.cloudinit
  labels                  = local.labels
  tags                    = [local.name]

  boot_disk {
    auto_delete = true

    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.main.name
    stack_type = local.cloud_config.ipv6 ? "IPV4_IPV6" : "IPV4_ONLY"

    access_config {
      nat_ip       = google_compute_address.algo.address
      network_tier = "STANDARD"
    }

    dynamic "ipv6_access_config" {
      iterator = ipv6
      for_each = local.cloud_config.ipv6 ? ["PREMIUM"] : []

      content {
        network_tier = ipv6.value
      }
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_key.public}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
