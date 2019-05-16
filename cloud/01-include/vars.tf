variable "algo_provider" {}
variable "region" {}
variable "max_mss" {}
variable "BetweenClients_DROP" {}
variable "strongswan_log_level" {}
variable "ipsec_enabled" {}
variable "wireguard_enabled" {}
variable "dns_encryption" {}
variable "unmanaged" {}

variable "vpn_users" {
  type = list(string)
}

variable "adblock_lists" {
  type = list(string)
}

variable "unattended_reboot" {
  type = map(string)
}

variable "dnscrypt_servers" {
  type = map(string)
}

variable "ipv4_dns_servers" {
  type = list(string)
}

variable "ipv6_dns_servers" {
  type = list(string)
}

# Prompts

variable "algo_name" {
  description = "Name the vpn server"
}

variable "ondemand_cellular" {
  description = <<-EOF
                  Do you want macOS/iOS IPsec clients to enable 'Connect On Demand' when connected to cellular networks?
                  [y/N]
                  EOF
}
variable "ondemand_wifi" {
  description = <<-EOF
                  Do you want macOS/iOS IPsec clients to enable 'Connect On Demand' when connected to Wi-Fi?
                  [y/N]
                  EOF
}

variable "ondemand_wifi_exclude" {
  description = <<-EOF
                  List the names of any trusted Wi-Fi networks where macOS/iOS IPsec clients should not use 'Connect On Demand'
                  (e.g., your home network. Comma-separated value, e.g., HomeNet,OfficeWifi,AlgoWiFi).
                  To skip enter "no"
                  EOF
}

variable "windows" {
  description = <<-EOF
                  Do you want the VPN to support Windows 10 or Linux Desktop clients?
                  (enables compatible ciphers and key exchange, less secure)
                  [y/N]
                  EOF
}

variable "dns_adblocking" {
  description = <<-EOF
                  Do you want to install an ad blocking DNS resolver on this VPN server?
                  [y/N]
                  EOF
}

variable "ssh_tunneling" {
  description = <<-EOF
                  Do you want each user to have their own account for SSH tunneling?
                  [y/N]
                  EOF
}

# Variables

provider "random" {
  version = "~> 2.1"
}

resource "random_integer" "local_service_ip" {
  min     = 1
  max     = 16777214
}

locals {
  true_exp = "/^(y|Y|true|yes)$/"

  exclude_networks = [
    for i in split(",", var.ondemand_wifi_exclude):
    i
    if length(i) > 0
  ]

  ondemand = {
    cellular     = replace(var.ondemand_cellular, local.true_exp, "yes") == "yes" ? true : false
    wifi         = replace(var.ondemand_wifi, local.true_exp, "yes") == "yes" ? true : false
    wifi_exclude = replace(var.ondemand_wifi_exclude, "/^(no|n|N|false)$/", "no") == "no" ? [] : local.exclude_networks

  }

  components = {
    ipsec          = var.ipsec_enabled
    wireguard      = var.wireguard_enabled
    dns_encryption = var.dns_encryption
    dns_adblocking = replace(var.dns_adblocking, local.true_exp, "yes") == "yes" ? true : false
    ssh_tunneling  = replace(var.ssh_tunneling, local.true_exp, "yes") == "yes" ? true : false
    windows        = replace(var.windows, local.true_exp, "yes") == "yes" ? true : false
  }

  local_service_ip = cidrhost("10.0.0.0/8", random_integer.local_service_ip.result)
}
