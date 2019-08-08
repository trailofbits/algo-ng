variable "region" {}
variable "algo_name" {}
variable "ssh_public_key" {}
variable "user_data" {}
variable "resource_group_name" {}
variable "algo_ip" {}

variable "wireguard_network" {
  type = map(string)

  default = {
    ipv4 = "10.19.49.0/24"
    ipv6 = "fd9d:bc11:4021::/48"
    port = 51820
  }
}

variable "image" {
  default = "18.04-LTS"
}

variable "size" {
  default = "Basic_A0"
}

variable "ipv6" {
  default = false
}
