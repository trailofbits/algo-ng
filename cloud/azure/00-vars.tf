variable "vpn_users" { type = "list" }
variable "algo_name" {}
variable "algo_provider" {}
variable "region" {}
variable "components" { type = "map" }
variable "max_mss" {}
variable "system_upgrade" {}

variable "unmanaged" {
  default = false
}
