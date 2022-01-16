variable "region" {}
variable "algo_name" {}
variable "ssh_public_key" {}
variable "ssh_private_key" {}
variable "config" {}

variable "image" {
  default = "ubuntu-20-04-x64"
}

variable "size" {
  default = "s-1vcpu-1gb"
}

variable "ipv6" {
  default = true
}
