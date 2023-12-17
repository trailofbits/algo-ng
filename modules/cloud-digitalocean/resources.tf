resource "digitalocean_ssh_key" "main" {
  name       = var.config.algo_name
  public_key = var.config.ssh_public_key
}

resource "digitalocean_floating_ip" "main" {
  region = var.config.cloud.region
}

resource "digitalocean_tag" "main" {
  name = "App:AlgoVPN"
}

resource "digitalocean_floating_ip_assignment" "main" {
  ip_address = digitalocean_floating_ip.main.ip_address
  droplet_id = digitalocean_droplet.main.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_firewall" "main" {
  name        = var.config.algo_name
  droplet_ids = [digitalocean_droplet.main.id]
  tags        = [digitalocean_tag.main.id]

  dynamic "inbound_rule" {
    iterator = rule
    for_each = [
      {
        "port" : 22
        "protocol" = "tcp"
      },
      {
        "port" : var.config.tfvars.wireguard.port,
        "protocol" = "udp"
      },
      {
        "port" : null
        "protocol" = "icmp"
      }
    ]

    content {
      source_addresses = ["0.0.0.0/0", "::/0"]
      protocol         = rule.value.protocol
      port_range       = rule.value.port
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

resource "digitalocean_droplet" "main" {
  name      = var.config.algo_name
  image     = var.config.cloud.image
  size      = var.config.cloud.size
  region    = var.config.cloud.region
  tags      = [digitalocean_tag.main.id]
  ssh_keys  = [digitalocean_ssh_key.main.id]
  ipv6      = var.config.cloud.ipv6
  user_data = var.config.user_data.cloudinit

  lifecycle {
    create_before_destroy = true
  }

  connection {
    type        = "ssh"
    host        = self.ipv4_address
    port        = 22
    user        = "root"
    private_key = var.config.ssh_private_key
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait  >/dev/null",
      "while ! systemctl --quiet is-system-running; do sleep 3; done",
    ]
  }
}
