variable "server_address" {}
variable "vpn_users" { type = "list" }
variable "algo_ssh_private_pem" {}
variable "DEPLOY_dns_adblocking" {}
variable "DEPLOY_ssh_tunneling" {}
variable "DEPLOY_security" {}
variable "ssh_user" { default = "root" }
variable "algo_config" {}
variable "ca_cert" {}
variable "server_cert" {}
variable "server_key" {}
variable "crl" {}
