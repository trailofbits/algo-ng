# Possible values: google, cloudflare
variable "dns_encryption_provider" {
  default = "cloudflare"
}

# DNS servers which will be used if dns_encryption disabled
variable "ipv4_dns_servers" {
  default = "1.1.1.1,1.0.0.1"
}

variable "ipv6_dns_servers" {
  default = "2606:4700:4700::1111,2606:4700:4700::1001"
}

# IP address for the local dns resolver
variable "local_service_ip" {
  default = "172.16.0.1"
}

# Block traffic between connected clients
variable "BetweenClients_DROP" {
  default = true
}

variable "strongswan_log_level" {
  default = "2"
}

variable "adblock_lists" {
  default =<<EOF
http://winhelp2002.mvps.org/hosts.txt
https://adaway.org/hosts.txt
https://www.malwaredomainlist.com/hostslist/hosts.txt
https://hosts-file.net/ad_servers.txt
EOF
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
    port = 51820
  }
}
