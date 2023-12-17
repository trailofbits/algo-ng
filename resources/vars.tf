variable "config" {}

# variable "ondemand_cellular" {
#   default     = false
#   description = <<-EOF
#                   Do you want macOS/iOS IPsec clients to enable 'Connect On Demand' when connected to cellular networks?
#                   [y/N]
#                   EOF
# }
# variable "ondemand_wifi" {
#   default     = false
#   description = <<-EOF
#                   Do you want macOS/iOS IPsec clients to enable 'Connect On Demand' when connected to Wi-Fi?
#                   [y/N]
#                   EOF
# }

# variable "ondemand_wifi_exclude" {
#   default     = "no"
#   description = <<-EOF
#                   List the names of any trusted Wi-Fi networks where macOS/iOS IPsec clients should not use 'Connect On Demand'
#                   (e.g., your home network. Comma-separated value, e.g., HomeNet,OfficeWifi,AlgoWiFi).
#                   To skip enter "no"
#                   EOF
# }

# variable "dns_adblocking" {
#   default     = false
#   description = <<-EOF
#                   Do you want to install an ad blocking DNS resolver on this VPN server?
#                   [y/N]
#                   EOF
# }

# variable "ssh_tunneling" {
#   default     = false
#   description = <<-EOF
#                   Do you want each user to have their own account for SSH tunneling?
#                   [y/N]
#                   EOF
# }

# #
# # Variables
# #

# resource "random_integer" "local_service_ip" {
#   min = 1
#   max = 16777214
# }

# locals {
#   true_exp = "/^(y|Y|true|yes)$/"

#   exclude_networks = [
#     for i in split(",", var.ondemand_wifi_exclude) :
#     i
#     if length(i) > 0
#   ]

#   prompts = {
#     dns_adblocking = replace(var.dns_adblocking, local.true_exp, "yes") == "yes" ? true : false
#     ssh_tunneling  = replace(var.ssh_tunneling, local.true_exp, "yes") == "yes" ? true : false

#     ondemand = {
#       cellular     = replace(var.ondemand_cellular, local.true_exp, "yes") == "yes" ? true : false
#       wifi         = replace(var.ondemand_wifi, local.true_exp, "yes") == "yes" ? true : false
#       wifi_exclude = replace(var.ondemand_wifi_exclude, "/^(no|n|N|false)$/", "no") == "no" ? [] : local.exclude_networks
#     }
#   }

#   calculated = {
#     ipsec_dns = {
#       ipv4 = cidrhost(var.config.wireguard.ipv4, 1)
#       ipv6 = cidrhost(var.config.wireguard.ipv6, 1)
#     }

#     wireguard_dns = {
#       ipv4 = cidrhost(var.config.ipsec.ipv4, 1)
#       ipv6 = cidrhost(var.config.ipsec.ipv6, 1)
#     }
#   }

#   config = merge(local.prompts, local.calculated, var.config)
# }
