resource "local_sensitive_file" "wireguard" {
  for_each = local.wireguard_users

  content = templatefile(
    "${path.module}/templates/wireguard.conf", {
      config       = var.algo_config
      cloud_config = var.cloud_config
      PrivateKey   = local.wireguard_config.keys.clients[each.key].private_key

      Address = {
        ipv4 = "${local.wireguard_config.peers[each.key].ipv4}/32"
        ipv6 = "${local.wireguard_config.peers[each.key].ipv6}/128"
      }

      DNS = join(",", concat(
        var.dns.ipv4,
        var.cloud_config.ipv6 ? var.dns.ipv6 : []
      ))

      Peer = {
        PublicKey    = local.wireguard_config.keys.server.public_key
        Endpoint     = "${var.cloud_config.server_ip}:${var.algo_config.wireguard.port}"
        PresharedKey = local.wireguard_config.keys.peers_psk[each.key].private_key
      }
    }
  )

  filename             = "${var.local_path}/wireguard/${each.key}.conf"
  file_permission      = "0600"
  directory_permission = "0700"
}
