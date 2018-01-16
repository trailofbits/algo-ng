locals {
  default_name_prefix = "do"
  algo_ssh_private    = "configs/${local.default_name_prefix}-${var.algo_ssh_private}"
}

module "tls" {
  source            = "../../modules/tls/"
  algo_ssh_private  = "${local.algo_ssh_private}"
}

module "user-data" {
  source = "../../modules/user-data/"
}

module "cloud-digitalocean" {
  source              = "../../modules/cloud-digitalocean/"
  # do_token            = "${var.do_token}"
  image               = "${var.image["digitalocean"]}"
  size                = "${var.size["digitalocean"]}"
  region              = "${var.region}"
  public_key_openssh  = "${module.tls.public_key_openssh}"
  user_data           = "${module.user-data.template_cloudinit_config}"
  algo_name           = "${var.algo_name}"
}

module "algo-deploy" {
  source                   = "../../modules/algo-deploy/"
  vpn_users                = "${var.vpn_users}"
  ca_password              = "${var.ca_password}"
  algo_ssh_private         = "${local.algo_ssh_private}"
  private_key_pem          = "${module.tls.private_key_pem}"
  DEPLOY_vpn               = "${var.components["vpn"]}"
  DEPLOY_dns_adblocking    = "${var.components["dns_adblocking"]}"
  DEPLOY_ssh_tunneling     = "${var.components["ssh_tunneling"]}"
  DEPLOY_security          = "${var.components["security"]}"
  server_address           = "${module.cloud-digitalocean.server_address}"
}
