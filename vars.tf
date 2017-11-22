variable "vpn_users" {
  description = "Add as many users as you want for your VPN server here. Credentials will be generated for each one"
  default = [
    "dan",
    "jack",
  ]
}

variable "cloud_digitalocean" {
  default = "true"
}

variable "algo_instance" {
  default = ""
}
