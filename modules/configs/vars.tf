variable "vpn_users" { type = "list" }
variable "components" { type = "map" }
variable "ipv6" { default = false }
variable "algo_config" {}
variable "server_address" {}
variable "ca_cert" {}
variable "client_p12_pass" {}
variable "clients_p12" {
  type    = "list"
  default = []
}
