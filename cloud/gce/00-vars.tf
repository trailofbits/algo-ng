variable "vpn_users" { type = "list" }
variable "algo_name" {}
variable "algo_provider" {}
variable "region" {}
variable "components" { type = "map" }
variable "image" { type = "map" }
variable "size" { type = "map" }
variable "google_credentials" {}

variable "unmanaged" {
  default = false
}
