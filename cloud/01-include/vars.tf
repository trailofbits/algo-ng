variable "vpn_users" {
  type = list(string)
}

variable "algo_name" {
}

variable "algo_provider" {
}

variable "region" {
}

variable "components" {}

# Config
variable "max_mss" {
}

variable "BetweenClients_DROP" {
}

variable "system_upgrade" {
}

variable "strongswan_log_level" {
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

variable "local_service_ip" {
}

variable "unmanaged" {
}

# VPN On Demand
variable "ondemand" {
  type = object({ cellular = bool, wifi = bool, wifi_exclude = string })

  default = {
    cellular = false
    wifi     = false
    # List the names of trusted Wi-Fi networks (if any) that macOS/iOS clients exclude from using the VPN
    # (e.g., your home network. Comma-separated value, e.g., HomeNet,OfficeWifi)
    wifi_exclude = ""
  }
}
