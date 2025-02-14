locals {
  tags = {
    App       = "AlgoVPN"
    Workspace = terraform.workspace
    DeployID  = var.deploy_id
  }

  cloud_config = var.algo_config.clouds.digitalocean

  wireguard_ports = [{
    "port" : var.algo_config.wireguard.port,
    "protocol" = "udp"
  }]

  ipsec_ports = [{
    "port" : 500,
    "protocol" = "udp"
    },
    {
      "port" : 4500,
      "protocol" = "udp"
  }]

  vpn_ports = concat(
    var.algo_config.wireguard.enabled ? local.wireguard_ports : [],
    var.algo_config.ipsec.enabled ? local.ipsec_ports : [],
  )
}

resource "digitalocean_ssh_key" "main" {
  name       = "algo-vpn-${var.deploy_id}"
  public_key = var.ssh_key.public
}

resource "digitalocean_floating_ip" "main" {
  region = local.cloud_config.region
}

resource "digitalocean_tag" "main" {
  for_each = local.tags
  name     = each.key
}

resource "digitalocean_droplet" "main" {
  name      = "algo-vpn-${var.deploy_id}"
  image     = local.cloud_config.image
  size      = local.cloud_config.size
  region    = local.cloud_config.region
  tags      = [for o in digitalocean_tag.main : o.id]
  ssh_keys  = [digitalocean_ssh_key.main.id]
  ipv6      = local.cloud_config.ipv6
  user_data = var.user_data.cloudinit

  lifecycle {
    create_before_destroy = true
  }

  connection {
    type        = "ssh"
    host        = self.ipv4_address
    port        = 22
    user        = "root"
    private_key = var.ssh_key.private
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait  >/dev/null",
      "while ! systemctl --quiet is-system-running; do sleep 3; done",
    ]
  }
}

resource "digitalocean_floating_ip_assignment" "main" {
  ip_address = digitalocean_floating_ip.main.ip_address
  droplet_id = digitalocean_droplet.main.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_firewall" "main" {
  name        = "algo-vpn-${var.deploy_id}"
  droplet_ids = [digitalocean_droplet.main.id]
  tags        = [for o in digitalocean_tag.main : o.id]

  dynamic "inbound_rule" {
    iterator = rule
    for_each = concat([
      {
        "port" : 22
        "protocol" = "tcp"
      },
      {
        "port" : null
        "protocol" = "icmp"
      }
    ], local.vpn_ports)

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
