resource "x25519_private_key" "wg_client" {
  for_each = toset(var.config.vpn_users)
}

resource "x25519_private_key" "wg_server" {}

resource "x25519_private_key" "wg_peers_psk" {
  for_each = toset(var.config.vpn_users)
}

resource "random_integer" "ip_user_seed" {
  for_each = toset(var.config.vpn_users)
  min      = 2
  max      = var.config.wireguard.max_hosts
  seed     = each.key
}

locals {
  wg_server_ip = {
    ipv4 = "${cidrhost(var.config.wireguard.ipv4, 1)}/32"
    ipv6 = "${cidrhost(var.config.wireguard.ipv6, 1)}/128"
  }

  wg_peers = [
    for user in var.config.vpn_users : {
      User         = user
      PublicKey    = x25519_private_key.wg_client[user].public_key
      PresharedKey = x25519_private_key.wg_peers_psk[user].private_key
      AllowedIPs = {
        ipv4 = "${cidrhost(var.config.wireguard.ipv4, random_integer.ip_user_seed[user].result)}/32",
        ipv6 = "${cidrhost(var.config.wireguard.ipv6, random_integer.ip_user_seed[user].result)}/128"
      }
    }
  ]

  wg0_conf = templatefile(
    "${path.module}/templates/wireguard/wg0.conf", {
      Address    = local.wg_server_ip
      ListenPort = contains(var.wg_ports_avoid, var.config.wireguard.port) ? var.wg_port_actual : var.config.wireguard.port
      PrivateKey = x25519_private_key.wg_server.private_key
      Peers      = local.wg_peers
      ipv6       = var.config.local.cloud.ipv6
      Subnets = {
        ipv4 = var.config.wireguard.ipv4
        ipv6 = var.config.wireguard.ipv6
      }
    }
  )
}

resource "null_resource" "wireguard-script" {
  connection {
    type        = "ssh"
    host        = var.config.local.server_address
    port        = 22
    user        = var.config.local.ssh_user
    private_key = var.config.local.ssh_private_key
    timeout     = "30m"
  }

  triggers = var.triggers

  provisioner "file" {
    content     = local.wg0_conf
    destination = "/opt/algo/configs/wireguard/wg0.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /opt/algo/scripts/wireguard.sh"
    ]
  }

  depends_on = [
    null_resource.common
  ]
}

resource "null_resource" "wireguard-config" {
  connection {
    type        = "ssh"
    host        = var.config.local.server_address
    port        = 22
    user        = var.config.local.ssh_user
    private_key = var.config.local.ssh_private_key
    timeout     = "30m"
  }

  triggers = merge(var.triggers,
    { wg0_conf = md5(local.wg0_conf) }
  )

  provisioner "file" {
    content     = local.wg0_conf
    destination = "/opt/algo/configs/wireguard/wg0.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash -c 'wg syncconf wg0 <(wg-quick strip wg0)'"
    ]
  }

  depends_on = [
    null_resource.wireguard-script
  ]
}

output "wireguard_config" {
  value = {
    keys = {
      clients   = x25519_private_key.wg_client
      peers_psk = x25519_private_key.wg_peers_psk
      server    = x25519_private_key.wg_server
    }
    ip_seeds = random_integer.ip_user_seed
    server = {
      ip = local.wg_server_ip
    }
  }
}
