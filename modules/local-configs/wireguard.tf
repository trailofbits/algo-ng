resource "local_file" "wireguard" {
  for_each = toset(var.config.vpn_users)

  sensitive_content = templatefile(
    "${path.module}/templates/wireguard.conf", {
      _config    = var.config
      PrivateKey = var.wireguard_config.keys.clients[each.key].private_key
      Address = {
        ipv4 = cidrhost(var.config.wireguard.ipv4, var.wireguard_config.ip_seeds[each.key].result)
        ipv6 = cidrhost(var.config.wireguard.ipv6, var.wireguard_config.ip_seeds[each.key].result)
      }

      DNS = var.config.dns.encryption.enabled || var.config.dns.adblocking.enabled ? {
        ipv4 = var.wireguard_config.server.ip.ipv4
        ipv6 = var.wireguard_config.server.ip.ipv6
        } : {
        ipv4 = join(",", var.config.dns.resolvers.ipv4)
        ipv6 = join(",", var.config.dns.resolvers.ipv6)
      }

      Peer = {
        PublicKey    = var.wireguard_config.keys.server.public_key
        Endpoint     = "${var.config.cloud-local.server_address}:${var.config.wireguard.port}"
        PresharedKey = var.wireguard_config.keys.peers_psk[each.key].public_key
      }
    }
  )

  filename             = "${var.algo_config}/wireguard/${each.key}.conf"
  file_permission      = "0600"
  directory_permission = "0700"
}
