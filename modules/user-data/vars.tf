variable "vpn_users" {
  type = list(string)
}

variable "components" { }

variable "gzip" {
  default = false
}

variable "base64_encode" {
  default = false
}

variable "ipv6" {
  default = false
}

variable "unmanaged" {
  default = false
}

variable "pki" {}

variable "ipsec_network" {
  type = map(string)

  default = {
    ipv4 = "10.19.48.0/24"
    ipv6 = "fd9d:bc11:4020::/48"
  }
}

variable "wireguard_network" {
  type = map(string)

  default = {
    ipv4 = "10.19.49.0/24"
    ipv6 = "fd9d:bc11:4021::/48"
    port = 51820
  }
}

variable "ciphers" {
  type = map(string)

  default = {
    ike = "aes256gcm16-prfsha512-ecp384!"
    esp = "aes256gcm16-ecp384!"
  }
}

variable "ciphers_compat" {
  type = map(string)

  default = {
    ike = "aes256gcm16-prfsha512-ecp384,aes256-sha2_512-prfsha512-ecp384,aes256-sha2_384-prfsha384-ecp384!"
    esp = "aes256gcm16-ecp384,aes256-sha2_512-prfsha512-ecp384!"
  }
}

# If you're behind NAT or a firewall and you want to receive incoming connections long after network traffic has gone silent.
# This option will keep the "connection" open in the eyes of NAT.
# See: https://www.wireguard.com/quickstart/#nat-and-firewall-traversal-persistence
variable "WireGuard_PersistentKeepalive" {
  default = 0
}
