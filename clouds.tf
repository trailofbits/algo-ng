module "digitalocean" {
  count  = var.config.cloud == "digitalocean" ? 1 : 0
  source = "./modules/cloud-digitalocean/"
  config = local.cloud-config
}

module "ec2" {
  count  = var.config.cloud == "ec2" ? 1 : 0
  source = "./modules/cloud-ec2/"
  config = local.cloud-config
}

module "lightsail" {
  count  = var.config.cloud == "lightsail" ? 1 : 0
  source = "./modules/cloud-lightsail/"
  config = local.cloud-config

  providers = {
    aws = aws.lightsail
  }
}

# module "gce" {
#   count  = var.config.cloud_provider == "gce" ? 1 : 0
#   source = "../../modules/cloud-gce/"

#   region  = var.config.clouds[var.config.cloud_provider].region
#   image   = var.config.clouds[var.config.cloud_provider].image
#   size    = var.config.clouds[var.config.cloud_provider].size
#   options = var.config.clouds[var.config.cloud_provider].options

#   algo_name       = var.algo_name
#   ssh_public_key  = module.tls.default.ssh.public_key_openssh
#   ssh_private_key = module.tls.default.ssh.private_key_pem
# }

# module "azure" {
#   count  = var.config.cloud_provider == "azure" ? 1 : 0
#   source = "../../modules/cloud-azure/"

#   region  = var.config.clouds[var.config.cloud_provider].region
#   image   = var.config.clouds[var.config.cloud_provider].image
#   size    = var.config.clouds[var.config.cloud_provider].size
#   options = var.config.clouds[var.config.cloud_provider].options

#   algo_name       = var.algo_name
#   ssh_public_key  = module.tls.default.ssh.public_key_openssh
#   ssh_private_key = module.tls.default.ssh.private_key_pem
# }
