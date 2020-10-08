variable "google_credentials" {
  description = "Either the path to or the contents of a service account key file in JSON format"
}

resource "google_compute_address" "main" {
  name         = var.algo_name
  region       = var.config.clouds.gce.region
  address_type = "EXTERNAL"
}

locals {
  server_address = google_compute_address.main.address
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
  ipv6          = false
  config        = local.config
  pki           = module.tls.pki
}

module "cloud" {
  source             = "../../modules/cloud-gce/"
  region             = var.config.clouds.gce.region
  algo_name          = var.algo_name
  server_address     = local.server_address
  ssh_public_key     = module.tls.ssh_public_key
  user_data          = module.user-data.template_cloudinit_config
  image              = var.config.clouds.gce.image
  size               = var.config.clouds.gce.size
  google_credentials = var.google_credentials
  config             = var.config
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
