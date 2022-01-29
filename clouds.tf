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

module "azure" {
  count  = var.config.cloud == "azure" ? 1 : 0
  source = "./modules/cloud-azure/"
  config = local.cloud-config
}

module "gce" {
  count  = var.config.cloud == "gce" ? 1 : 0
  source = "./modules/cloud-gce/"
  config = local.cloud-config
}

module "scaleway" {
  count  = var.config.cloud == "scaleway" ? 1 : 0
  source = "./modules/cloud-scaleway/"
  config = local.cloud-config
}

module "hetzner" {
  count  = var.config.cloud == "hetzner" ? 1 : 0
  source = "./modules/cloud-hetzner/"
  config = local.cloud-config
}
