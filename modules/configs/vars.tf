variable "vpn_users" { type = "list" }
variable "components" { type = "map" }
variable "ipv6" { default = false }
variable "algo_config" {}
variable "server_address" {}
variable "ca_cert" {}
variable "server_cert" {}
variable "server_key" {}
variable "crl" {}
variable "client_p12_pass" {}
variable "private_key" {}
variable "server_id" {}
variable "wg_users_private" { type = "list" }
variable "wg_users_public" { type = "list" }
variable "wireguard_network" { type = "map" }
variable "local_service_ip" {}
variable "ssh_user" {
  default = "ubuntu"
}

variable "clients_p12_base64" {
  type    = "list"
  default = []
}