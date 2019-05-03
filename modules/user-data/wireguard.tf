locals {
  wg_conf = {
    InterfaceAddress    = "${cidrhost(var.wireguard_network["ipv4"], 1)}${var.ipv6 == 0 ? "" : ",${cidrhost(var.wireguard_network["ipv6"], 1)}"}"
    InterfaceListenPort = var.wireguard_network["port"]
    InterfacePrivateKey = var.pki.wireguard.server_private_key
    vpn_users           = var.vpn_users
    ipv6                = var.ipv6
    wireguard_network   = var.wireguard_network
  }

  wireguard = {
    wg_conf            = templatefile("${path.module}/files/wireguard/wg0.conf", { vars = local.wg_conf })
    private_keys       = var.pki.wireguard.client_private_keys
    server_private_key = var.pki.wireguard.server_private_key
    vpn_users          = var.vpn_users
  }
}
