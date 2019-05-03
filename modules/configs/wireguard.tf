data "template_file" "wireguard-clients" {
  count    = length(var.vpn_users)
  template = file("${path.module}/files/wireguard.conf")

  vars = {
    PrivateKey              = base64encode(var.pki.wireguard.client_private_keys[count.index])
    Address                 = "${cidrhost(var.wireguard_network["ipv4"], 2 + count.index)}/32${var.ipv6 == 0 ? "" : ",${cidrhost(var.wireguard_network["ipv6"], 2 + count.index)}/128"}"
    DNS                     = var.local_service_ip
    PeerPublicKey           = data.external.wg-server-pub.result["result"]
    PeerEndpoint            = "${var.server_address}:${var.wireguard_network["port"]}"
    PeerPersistentKeepalive = var.WireGuard_PersistentKeepalive == 0 ? 0 : var.WireGuard_PersistentKeepalive
  }
}

resource "local_file" "wireguard" {
  count    = length(var.vpn_users)
  filename = "${var.algo_config}/wireguard/${var.vpn_users[count.index]}.conf"
  content  = element(data.template_file.wireguard-clients.*.rendered, count.index)
}
