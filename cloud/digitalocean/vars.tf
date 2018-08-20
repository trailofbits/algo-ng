variable "vpn_users" { type = "map" }
variable "algo_name" { default = "algo-local" }
variable "algo_provider" {}
variable "region" {}
variable "components" { type = "map" }
variable "image" { type = "map" }
variable "size" { type = "map" }
