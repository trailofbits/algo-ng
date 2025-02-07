# output "AlgoVPN" {
#   value = {
#     Terraform = {
#       Workspace = terraform.workspace
#     }

#     Cloud = {
#       Vendor      = local.cloud_name
#       "Deploy ID" = random_string.deploy_id.result
#       "Server IP" = local.cloud_module.server_address
#     }

#     Config = {
#       "Configs directory" = local.algo_config
#     }

#     Components = {
#       "WireGuard"     = var.config.wireguard.enabled
#       "SSH tunneling" = var.config.ssh_tunneling

#       "DNS" = {
#         "Encryption"  = var.config.dns.encryption.enabled
#         "Ad blocking" = var.config.dns.adblocking.enabled
#       }
#     }
#   }
# }
