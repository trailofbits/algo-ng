variable "vpn_users" {
  type = list(string)
}

variable "components" {
  type = map(string)
}

variable "ipv6" {
  default = false
}

variable "algo_config" {}

variable "server_address" {}

variable "client_p12_pass" {}

variable "ssh_private_key" {}

variable "server_id" {
}

variable "pki" {}

variable "wireguard_network" {
  type = map(string)
}

variable "local_service_ip" {
}

variable "ssh_user" {
  default = "ubuntu"
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

# If you're behind NAT or a firewall and you want to receive incoming connections long after network traffic has gone silent.
# This option will keep the "connection" open in the eyes of NAT.
# See: https://www.wireguard.com/quickstart/#nat-and-firewall-traversal-persistence
variable "WireGuard_PersistentKeepalive" {
  default = 0
}
