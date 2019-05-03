variable "region" {}
variable "algo_name" {}
variable "public_key_openssh" {}
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
  default = "ubuntu-disco-19.04"
}

variable "size" {
  default = "t2.micro"
}

variable "ipv6" {
  default = true
}

variable "encrypted" {
  default = false
}

variable "kms_key_id" {
  default = ""
}

variable "algo_ip" {}
