module "ssh-key" {
  source      = "../../modules/ssh-key/"
  algo_config = "${local.algo_config}"
}

module "tls" {
  source            = "../../modules/tls/"
  server_address    = "${module.cloud-digitalocean.server_address}"
  vpn_users         = "${var.vpn_users}"
  algo_config       = "${local.algo_config}"
  components        = "${var.components}"
}

module "user-data" {
  source                      = "../../modules/user-data/"
  vpn_users                   = "${var.vpn_users}"
  clients_public_key_openssh  = "${module.tls.clients_public_key_openssh}"
  components                  = "${var.components}"
  ipv6                        = "${module.cloud-digitalocean.ipv6}"
  unmanaged                   = "${var.unmanaged}"
}

module "cloud-digitalocean" {
  source              = "../../modules/cloud-digitalocean/"
  region              = "${var.region}"
  public_key_openssh  = "${module.ssh-key.public_key_openssh}"
  user_data           = "${module.user-data.template_cloudinit_config}"
  algo_name           = "${var.algo_name}"
}

module "configs" {
  source              = "../../modules/configs/"
  vpn_users           = "${var.vpn_users}"
  components          = "${var.components}"
  ipv6                = "${module.cloud-digitalocean.ipv6}"
  algo_config         = "${local.algo_config}"
  server_address      = "${module.cloud-digitalocean.server_address}"
  client_p12_pass     = "${module.tls.client_p12_pass}"
  clients_p12         = "${module.tls.clients_p12}"
  ca_cert             = "${module.tls.ca_cert}"
}
