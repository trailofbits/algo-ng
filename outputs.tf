# locals {
#   wireguard_dns = {
#     for i in values(local.config.wireguard_dns) :
#     "WireGuard" => i...
#     if local.config.dns.adblocking.enabled || local.config.dns.encryption.enabled
#   }

#   resolvers = {
#     for i in concat(var.config.dns.resolvers.ipv4, var.config.dns.resolvers.ipv6) :
#     "Resolvers" => i...
#     if ! local.config.dns.adblocking.enabled && ! local.config.dns.encryption.enabled
#   }

#   output = {
#     dns_resolvers = merge(local.wireguard_dns, local.resolvers)
#   }
# }

# output "AlgoVPN" {
#   value = {
#     Config = {
#       "Server address"            = local.server_address
#       "Config directory"          = "configs/${local.server_address}/"
#     }

#     Components = {
#       "WireGuard"     = local.config.wireguard.enabled
#       "SSH tunneling" = local.config.ssh_tunneling

#       "DNS" = {
#         "Encryption"  = local.config.dns.encryption.enabled
#         "Ad blocking" = local.config.dns.adblocking.enabled
#         "Servers"     = local.output.dns_resolvers
#       }
#     }
#   }
# }
