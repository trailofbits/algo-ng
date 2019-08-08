resource "digitalocean_floating_ip" "main" {
  region = var.config.clouds.digitalocean.region
}

locals {
  server_address = "${digitalocean_floating_ip.main.ip_address}"
  algo_config    = "${path.cwd}/configs/${local.server_address}"
}

module "tls" {
  source         = "../../modules/tls/"
  algo_config    = local.algo_config
  vpn_users      = var.config.vpn_users
  server_address = local.server_address
}

module "user-data" {
  source        = "../../modules/user-data/"
  base64_encode = false
  gzip          = false
  ipv6          = true
  config        = local.config
  pki           = module.tls.pki
}

module "cloud" {
  source         = "../../modules/cloud-digitalocean/"
  region         = var.config.clouds.digitalocean.region
  algo_name      = var.algo_name
  algo_ip        = digitalocean_floating_ip.main.id
  ssh_public_key = module.tls.ssh_public_key
  user_data      = module.user-data.template_cloudinit_config
  image          = var.config.clouds.digitalocean.image
  size           = var.config.clouds.digitalocean.size
}

module "configs" {
  source          = "../../modules/configs/"
  algo_config     = local.algo_config
  server_address  = local.server_address
  client_p12_pass = module.tls.client_p12_pass
  ssh_user        = module.cloud.ssh_user
  ssh_private_key = module.tls.ssh_private_key
  server_id       = module.cloud.server_id
  pki             = module.tls.pki
  config          = local.config
}
