resource "digitalocean_ssh_key" "main" {
  name       = var.algo_name
  public_key = var.ssh_public_key
}

resource "digitalocean_floating_ip" "main" {
  region = var.region
}

resource "digitalocean_tag" "main" {
  name = "Environment:Algo"
}

resource "digitalocean_droplet" "main" {
  depends_on = [digitalocean_floating_ip.main]
  name       = var.algo_name
  image      = var.image
  size       = var.size
  region     = var.region
  tags       = [digitalocean_tag.main.id]
  ssh_keys   = [digitalocean_ssh_key.main.id]
  ipv6       = true
  user_data  = module.user-data.cloud_config

  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_floating_ip_assignment" "main" {
  ip_address = digitalocean_floating_ip.main.ip_address
  droplet_id = digitalocean_droplet.main.id
}

resource "digitalocean_firewall" "main" {
  name        = var.algo_name
  droplet_ids = [digitalocean_droplet.main.id]

  dynamic "inbound_rule" {
    iterator = rule
    for_each = [
      "22:tcp",
      "${var.wireguard_network["port"]}:udp"
    ]

    content {
      source_addresses = ["0.0.0.0/0", "::/0"]
      protocol         = split(":", rule.value)[1]
      port_range       = split(":", rule.value)[0]
    }
  }

  dynamic "outbound_rule" {
    iterator = rule
    for_each = [
      "tcp",
      "udp",
    ]

    content {
      protocol   = rule.value
      port_range = "1-65535"
      destination_addresses = [
        "0.0.0.0/0",
        "::/0"
      ]
    }
  }
}
