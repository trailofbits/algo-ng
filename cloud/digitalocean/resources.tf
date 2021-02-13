module "tls" {
  source      = "../../modules/tls/"
  algo_config = local.algo_config
  vpn_users   = var.config.vpn_users
}

module "cloud" {
  source         = "../../modules/cloud-digitalocean/"
  region         = var.config.clouds.digitalocean.region
  algo_name      = var.algo_name
  ssh_public_key = module.tls.ssh_public_key
  image          = var.config.clouds.digitalocean.image
  size           = var.config.clouds.digitalocean.size
}

# module "configs" {
#   source          = "../../modules/configs/"
#   algo_config     = local.algo_config
#   server_address  = module.cloud.server_address
#   ssh_user        = module.cloud.ssh_user
#   ssh_private_key = module.tls.ssh_private_key
#   server_id       = module.cloud.server_id
#   pki             = module.tls.pki
#   # config          = local.config
# }

# resource "tls_x25519" "example" {
#   count = 3
# }

# output "test" {
#   value = tls_x25519.example
# }
