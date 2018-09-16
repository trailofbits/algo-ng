variable "image" {
  default = "18.04-LTS"
}

variable "size" {
  default = "Basic_A0"
}

variable "ipv6" {
  default = false
}

variable "region" {}
variable "algo_name" {}
variable "public_key_openssh" {}
variable "user_data" {}
