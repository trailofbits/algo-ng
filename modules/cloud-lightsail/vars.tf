variable "region" {}
variable "algo_name" {}
variable "public_key_openssh" {}
variable "user_data" {}
variable "wireguard_network" { type = "map" }

variable "image" {
  default = "ubuntu_18_04"
}

variable "size" {
  default = "nano_1_0"
}

variable "ipv6" {
  default = false
}
