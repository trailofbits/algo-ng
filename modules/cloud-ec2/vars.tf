variable "image" {
  type    = "map"
  default = {
    "ec2.name"      = "ubuntu-bionic-18.04"
    "ec2.owner"     = "099720109477"
  }
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

variable "region" {}
variable "algo_name" {}
variable "public_key_openssh" {}
variable "user_data" {}
