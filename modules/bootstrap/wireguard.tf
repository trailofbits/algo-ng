resource "tls_x25519" "wg_client" {
  provider = tls-x25519
  for_each = toset(var.config.vpn_users)
}

resource "tls_x25519" "wg_server" {
  provider = tls-x25519
}

resource "tls_x25519" "wg_peers_psk" {
  provider = tls-x25519
  for_each = toset(var.config.vpn_users)
}

resource "random_integer" "ip_id" {
  for_each = toset(var.config.vpn_users)
  min      = 2
  max      = var.config.wireguard.max_hosts
  seed     = each.key
}

locals {
  wg_server_ip = cidrhost(var.config.wireguard.ipv4, 1)

  wg_peers = [
    for user in var.config.vpn_users : {
      User         = user
      PublicKey    = tls_x25519.wg_client[user].public_key
      PresharedKey = tls_x25519.wg_client[user].private_key
      AllowedIPs = [
        cidrhost(var.config.wireguard.ipv4, random_integer.ip_id[user].result)
      ]
    }
  ]

  wg0_conf = templatefile(
    "${path.module}/templates/wireguard/wg0.conf", {
      Address    = local.wg_server_ip
      ListenPort = contains(var.wg_ports_avoid, var.config.wireguard.port) ? var.wg_port_actual : var.config.wireguard.port
      PrivateKey = tls_x25519.wg_server.private_key
      Peers      = local.wg_peers
    }
  )
}

resource "null_resource" "wireguard-script" {
  connection {
    type        = "ssh"
    host        = var.server_address
    port        = 22
    user        = var.ssh_user
    private_key = var.ssh_private_key
    timeout     = "30m"
  }

  triggers = var.triggers

  provisioner "file" {
    content     = local.wg0_conf
    destination = "/opt/algo/configs/wireguard/wg0.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /opt/algo/scripts/wireguard.sh"
    ]
  }

  depends_on = [
    null_resource.common
  ]
}

resource "null_resource" "wireguard-config" {
  connection {
    type        = "ssh"
    host        = var.server_address
    port        = 22
    user        = var.ssh_user
    private_key = var.ssh_private_key
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
      "bash -c 'wg syncconf wg0 <(wg-quick strip wg0)'"
    ]
  }

  depends_on = [
    null_resource.wireguard-script
  ]
}

output "wireguard_config" {
  value = {
    keys = {
      clients   = tls_x25519.wg_client
      peers_psk = tls_x25519.wg_peers_psk
      server    = tls_x25519.wg_server
    }
    ip_seeds = random_integer.ip_id
    server = {
      ip = local.wg_server_ip
    }
  }
}
