variable "vpn_users" { type = "list" }
variable "components" { type = "map" }
variable "gzip" { default = false }
variable "base64_encode" {  default = false}
variable "ipv6" { default = false }

variable "unmanaged" {
  default = false
}

variable "clients_public_key_openssh" {
  type    = "list"
  default = []
}
