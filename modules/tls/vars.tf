variable "algo_config" {}
variable "vpn_users" {}

variable "ssh_key_algorithm" {
  default = "RSA"
}

variable "ssh_key_rsa_bits" {
  default = "2048"
}
