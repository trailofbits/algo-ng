variable "region" {}
variable "algo_name" {}
variable "ssh_public_key" {}
variable "user_data" {}

variable "image" {
  default = "ubuntu-19-04-x64"
}

variable "size" {
  default = "s-1vcpu-1gb"
}

variable "ipv6" {
  default = true
}

variable "algo_ip" {}
