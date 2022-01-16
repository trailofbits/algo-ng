module "tls" {
  source      = "../../modules/tls/"
  algo_config = local.algo_config
  vpn_users   = var.config.vpn_users
}

module "cloud" {
  source          = "../../modules/cloud-digitalocean/"
  region          = var.config.digitalocean.region
  algo_name       = var.algo_name
  image           = var.config.digitalocean.image
  size            = var.config.digitalocean.size
  ssh_public_key  = module.tls.default.ssh.public_key_openssh
  ssh_private_key = module.tls.default.ssh.private_key_pem
}

module "bootstrap" {
  depends_on      = [module.cloud]
  source          = "../../modules/bootstrap/"
  server_address  = module.cloud.server_address
  ssh_user        = module.cloud.ssh_user
  ssh_private_key = module.tls.default.ssh.private_key_pem
  config          = var.config

  triggers = {
    server_id = module.cloud.server_id
    1         = 123
  }
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

# output "test" {
#   value = module.tls
# }

resource "local_file" "foo" {
  content         = module.tls.default.ssh.private_key_pem
  filename        = "/tmp/algo-sshs"
  file_permission = 0400
}
