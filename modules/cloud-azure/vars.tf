variable "region" {}
variable "algo_name" {}
variable "ssh_public_key" {}
variable "user_data" {}

variable "wireguard_network" {
  type = "map"
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
