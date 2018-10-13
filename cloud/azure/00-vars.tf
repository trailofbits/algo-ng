variable "vpn_users" { type = "list" }
variable "algo_name" {}
variable "algo_provider" {}
variable "region" {}
variable "components" { type = "map" }

# Config
variable "max_mss" {}
variable "BetweenClients_DROP" {}
variable "system_upgrade" {}
variable "strongswan_log_level" {}
variable "adblock_lists" { type = "list" }
variable "unattended_reboot" { type = "map" }
variable "dnscrypt_servers" { type = "map" }
variable "ipv4_dns_servers" { type = "list" }
variable "ipv6_dns_servers" { type = "list" }
variable "local_service_ip" {}
variable "unmanaged" {}

# VPN On Demand
variable "ondemand" {
  type          = "map"
  default {
    cellular      = false
    wifi          = false
    # List the names of trusted Wi-Fi networks (if any) that macOS/iOS clients exclude from using the VPN
    # (e.g., your home network. Comma-separated value, e.g., HomeNet,OfficeWifi)
    wifi_exclude  = ""
  }
}
