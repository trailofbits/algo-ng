locals {
  wireguard_dns = {
    for i in values(local.config.wireguard_dns) :
    "WireGuard" => i...
    if local.config.dns.adblocking.enabled || local.config.dns.encryption.enabled
  }

  ipsec_dns = {
    for i in values(local.config.ipsec_dns) :
    "IPsec" => i...
    if local.config.dns.adblocking.enabled || local.config.dns.encryption.enabled
  }

  resolvers = {
    for i in concat(var.config.dns.resolvers.ipv4, var.config.dns.resolvers.ipv6) :
    "Resolvers" => i...
    if ! local.config.dns.adblocking.enabled && ! local.config.dns.encryption.enabled
  }

  output = {
    dns_resolvers = merge(local.wireguard_dns, local.ipsec_dns, local.resolvers)
  }
}

output "AlgoVPN" {
  value = {
    Config = {
      "Server address"            = local.server_address
      "P12 and SSH keys password" = module.tls.client_p12_pass
      "Config directory"          = "configs/${local.server_address}/"

      "On Demand" = {
        Cellular = local.config.ondemand.cellular
        WiFi = {
          enabled = local.config.ondemand.wifi
          "exclude networks" = [
            for i in local.config.ondemand.wifi_exclude :
            i
            if local.config.ondemand.wifi
          ]
        }
      }
    }

    Components = {
      "IPsec"         = local.config.ipsec.enabled
      "WireGuard"     = local.config.wireguard.enabled
      "SSH tunneling" = local.config.ssh_tunneling

      "DNS" = {
        "Encryption"  = local.config.dns.encryption.enabled
        "Ad blocking" = local.config.dns.adblocking.enabled
        "Servers"     = local.output.dns_resolvers
      }
    }
  }
}
