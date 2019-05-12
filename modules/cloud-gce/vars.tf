variable "region" {}
variable "algo_name" {}
variable "ssh_public_key" {}
variable "user_data" {}
variable "server_address" {}

variable "wireguard_network" {
  type = map(string)

  default = {
    ipv4 = "10.19.49.0/24"
    ipv6 = "fd9d:bc11:4021::/48"
    port = 51820
  }
}

variable "google_credentials" {}

variable "image" {
  default = "ubuntu-os-cloud/ubuntu-1904"
}

variable "size" {
  default = "f1-micro"
}

variable "ipv6" {
  default = false
}
