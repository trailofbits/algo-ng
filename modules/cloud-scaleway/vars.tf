variable "region" {}
variable "algo_name" {}
variable "ssh_public_key" {}
variable "user_data" {}

variable "wireguard_network" {
  type = map(string)

  default = {
    ipv4 = "10.19.49.0/24"
    ipv6 = "fd9d:bc11:4021::/48"
    port = 51820
  }
}

variable "image" {
  default = "Ubuntu Bionic"
}

variable "size" {
  default = "START1-S"
}

variable "ipv6" {
  default = true
}

variable "server_address" {}
