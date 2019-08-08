locals {
  dnscrypt_proxy_toml = {
    server_names   = concat(var.config.dns.encryption.servers.ipv4, var.ipv6 ? var.config.dns.encryption.servers.ipv6 : [])
    ipv6           = var.ipv6 ? "true" : "false"
    blacklist_file = var.config.dns.adblocking.enabled ? "blacklist_file = 'blacklist.txt'" : ""
  }

  dns = {
    encryption = {
      apparmor_dnscrypt-proxy = file("${path.module}/files/dns/usr.bin.dnscrypt-proxy")
      dnscrypt_proxy_toml     = templatefile("${path.module}/files/dns/dnscrypt-proxy.toml", { vars = local.dnscrypt_proxy_toml })
      ip-blacklist            = file("${path.module}/files/dns/ip-blacklist.txt")
      adblock_sh              = file("${path.module}/files/dns/adblock.sh")
      adblock_lists           = join("\n", var.config.dns.adblocking.lists)
      wireguard_dns_address   = values(var.config.wireguard_dns)
      ipsec_dns_address       = values(var.config.ipsec_dns)
    }
  }
}
