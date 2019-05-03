variable "server_address" {
}

variable "vpn_users" {
  type = list(string)
}

variable "algo_config" {
}

variable "components" {
  type = map(string)
}
