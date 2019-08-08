locals {
  wg_conf = {
    InterfaceAddress    = [cidrhost(var.config.wireguard.ipv4, 1), var.ipv6 ? cidrhost(var.config.wireguard.ipv6, 1) : ""]
    InterfaceListenPort = var.config.wireguard.port
    InterfacePrivateKey = var.pki.wireguard.server_private_key
    vpn_users           = var.config.vpn_users
    ipv6                = var.ipv6
    wireguard = {
      ipv4 = var.config.wireguard.ipv4
      ipv6 = var.config.wireguard.ipv6
    }
  }

  wireguard = {
    wg_conf            = templatefile("${path.module}/files/wireguard/wg0.conf", { vars = local.wg_conf })
    private_keys       = var.pki.wireguard.client_private_keys
    server_private_key = var.pki.wireguard.server_private_key
    vpn_users          = var.config.vpn_users
  }
}
