# Possible values: google, cloudflare
variable "dns_encryption_provider" {
  default = "cloudflare"
}

# DNS servers which will be used if dns_encryption disabled
variable "ipv4_dns_servers" {
  type    = "list"
  default = [
    "1.1.1.1",
    "1.0.0.1"
  ]
}

variable "ipv6_dns_servers" {
  type    = "list"
  default = [
    "2606:4700:4700::1111",
    "2606:4700:4700::1001"
  ]
}

# IP address for the local dns resolver
variable "local_service_ip" {
  default = "172.16.0.1"
}

# Block traffic between connected clients
variable "BetweenClients_DROP" {
  default = true
}

# MSS is the TCP Max Segment Size
# Setting the 'max_mss' variable can solve some issues related to packet fragmentation
# This appears to be necessary on (at least) Google Cloud,
# however, some routers also require a change to this parameter
# See also:
# - https://github.com/trailofbits/algo/issues/216
# - https://github.com/trailofbits/algo/issues?utf8=%E2%9C%93&q=is%3Aissue%20mtu
# - https://serverfault.com/questions/601143/ssh-not-working-over-ipsec-tunnel-strongswan
# variable "max_mss" {
#   default = 1316
# }

variable "max_mss" {
  default = 0
}

variable "strongswan_log_level" {
  default = "2"
}

variable "adblock_lists" {
  type    = "list"
  default = [
    "http://winhelp2002.mvps.org/hosts.txt",
    "https://adaway.org/hosts.txt",
    "https://www.malwaredomainlist.com/hostslist/hosts.txt",
    "https://hosts-file.net/ad_servers.txt"
  ]
}

variable "ipsec_network" {
  type = "map"
  default = {
    ipv4 = "10.19.48.0/24"
    ipv6 = "fd9d:bc11:4020::/48"
  }
}

variable "wireguard_network" {
  type = "map"
  default = {
    ipv4 = "10.19.49.0/24"
    ipv6 = "fd9d:bc11:4021::/48"
    port = 51820
  }
}

variable "ciphers" {
  type    = "map"
  default = {
    ike = "aes256gcm16-prfsha512-ecp384!"
    esp = "aes256gcm16-ecp384!"
  }
}

variable "ciphers_compat" {
  type    = "map"
  default = {
    ike = "aes256gcm16-prfsha512-ecp384,aes256-sha2_512-prfsha512-ecp384,aes256-sha2_384-prfsha384-ecp384!"
    esp = "aes256gcm16-ecp384,aes256-sha2_512-prfsha512-ecp384!"
  }
}
