variable "region" {}
variable "algo_name" {}
variable "public_key_openssh" {}
variable "user_data" {}
variable "wireguard_network" { type = "map" }
variable "google_credentials" {}

variable "image" {
  default = "ubuntu-os-cloud/ubuntu-1804-lts"
}

variable "size" {
  default = "f1-micro"
}

variable "ipv6" {
  default = false
}
