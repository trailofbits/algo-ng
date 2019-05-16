variable "algo_config" {}
variable "server_address" {}
variable "client_p12_pass" {}
variable "ssh_private_key" {}
variable "server_id" {}
variable "pki" {}
variable "local_service_ip" {}

variable "vpn_users" {
  type = list(string)
}

variable "components" {
  type = map(string)
}

variable "ipv6" {
  default = false
}

variable "wireguard_network" {
  type = map(string)
}

variable "ssh_user" {
  default = "ubuntu"
}

# VPN On Demand
variable "ondemand" {
  type = object({ cellular = bool, wifi = bool, wifi_exclude = list(string) })

  default = {
    cellular     = false
    wifi         = false
    wifi_exclude = []
  }
}

# If you're behind NAT or a firewall and you want to receive incoming connections long after network traffic has gone silent.
# This option will keep the "connection" open in the eyes of NAT.
# See: https://www.wireguard.com/quickstart/#nat-and-firewall-traversal-persistence
variable "WireGuard_PersistentKeepalive" {
  default = 0
}
