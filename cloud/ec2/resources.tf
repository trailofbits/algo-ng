resource "aws_eip" "algo" {
  vpc = true
}

locals {
  server_address = aws_eip.algo.public_ip
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
  base64_encode = true
  gzip          = true
  ipv6          = true
  config        = local.config
  pki           = module.tls.pki
}

module "cloud" {
  source         = "../../modules/cloud-ec2/"
  region         = var.config.clouds.ec2.region
  algo_name      = var.algo_name
  algo_ip        = aws_eip.algo.id
  ssh_public_key = module.tls.ssh_public_key
  user_data      = module.user-data.template_cloudinit_config
  image          = var.config.clouds.ec2.image
  size           = var.config.clouds.ec2.size
  encrypted      = var.config.clouds.ec2.encrypted
  kms_key_id     = var.config.clouds.ec2.kms_key_id
  config         = var.config
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
