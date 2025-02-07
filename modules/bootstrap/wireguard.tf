resource "x25519_private_key" "wg_client" {
  for_each = local.wg_users
}

resource "x25519_private_key" "wg_server" {
  count = var.algo_config.wireguard.enabled ? 1 : 0
}

resource "x25519_private_key" "wg_peers_psk" {
  for_each = local.wg_users
}

resource "random_integer" "ip_user_seed" {
  for_each = local.wg_users
  min      = 2
  max      = local.wg_max_hosts
  seed     = each.key
}

locals {
  wg_max_hosts   = pow(2, 32 - split("/", var.algo_config.wireguard.ipv4)[1]) - 3
  wg_users       = var.algo_config.wireguard.enabled ? local.users : {}
  wg_port_actual = 51820
  wg_ports_avoid = [53]

  wg_server_ip = {
    ipv4 = "${cidrhost(var.algo_config.wireguard.ipv4, 1)}/32"
    ipv6 = "${cidrhost(var.algo_config.wireguard.ipv6, 1)}/128"
  }

  wg_peers_ip = {
    for u in var.algo_config.users : u => {
      ipv4 = cidrhost(var.algo_config.wireguard.ipv4, random_integer.ip_user_seed[u].result)
      ipv6 = cidrhost(var.algo_config.wireguard.ipv6, random_integer.ip_user_seed[u].result)
    }
  }

  wg_server_peers = try([
    for user in local.wg_users : {
      User         = user
      PublicKey    = x25519_private_key.wg_client[user].public_key
      PresharedKey = x25519_private_key.wg_peers_psk[user].private_key
      AllowedIPs = {
        ipv4 = "${local.wg_peers_ip[user].ipv4}/32",
        ipv6 = "${local.wg_peers_ip[user].ipv6}/128"
      }
    }
  ], [])

  wg0_conf = try(templatefile(
    "${path.module}/templates/wireguard/wg0.conf", {
      Address = local.wg_server_ip
      ListenPort = contains(
        local.wg_ports_avoid, var.algo_config.wireguard.port
      ) ? local.wg_port_actual : var.algo_config.wireguard.port

      PrivateKey = try(x25519_private_key.wg_server.0.private_key, null)
      Peers      = local.wg_server_peers
      ipv6       = var.cloud_config.ipv6
      Subnets = {
        ipv4 = var.algo_config.wireguard.ipv4
        ipv6 = var.algo_config.wireguard.ipv6
      }
    }
  ), null)
}

resource "null_resource" "wireguard-script" {
  count = var.algo_config.wireguard.enabled ? 1 : 0

  connection {
    type        = "ssh"
    timeout     = "30m"
    port        = 22
    host        = var.cloud_config.server_ip
    user        = var.cloud_config.ssh_user
    private_key = var.ssh_key.private
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
  count = var.algo_config.wireguard.enabled ? 1 : 0

  connection {
    type        = "ssh"
    timeout     = "30m"
    port        = 22
    host        = var.cloud_config.server_ip
    user        = var.cloud_config.ssh_user
    private_key = var.ssh_key.private
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
