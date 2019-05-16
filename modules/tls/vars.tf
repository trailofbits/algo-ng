variable "server_address" {}
variable "algo_config" {}

variable "vpn_users" {
  type = list(string)
}

variable "components" {
  type = map(string)
}

variable "ssh_key_algorithm" {
  default = "RSA"
}

variable "ssh_key_rsa_bits" {
  default = "2048"
}
