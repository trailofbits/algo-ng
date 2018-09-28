variable "ssh_private_key" {
  default = "configs/algo.ssh.pem"
}
variable "ssh_key_algorithm" {
  default = "ECDSA"
}
variable "ssh_key_ecdsa_curve" {
  default = "P384"
}
variable "ssh_key_rsa_bits" {
  default = "2048"
}

variable "algo_config" {}
