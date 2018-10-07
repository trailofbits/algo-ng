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
  max_mss                     = "${var.max_mss}"
  system_upgrade              = "${var.system_upgrade}"
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
  clients_p12_base64  = "${module.tls.clients_p12_base64}"
  ca_cert             = "${module.tls.ca_cert}"
  server_cert         = "${module.tls.server_cert}"
  server_key          = "${module.tls.server_key}"
  crl                 = "${module.tls.crl}"
  ssh_user            = "${module.cloud-digitalocean.ssh_user}"
  private_key         = "${module.ssh-key.private_key_pem}"
  server_id           = "${module.cloud-digitalocean.server_id}"
  wg_users_private    = "${module.user-data.wg_users_private}"
  wg_users_public     = "${module.user-data.wg_users_public}"
}
