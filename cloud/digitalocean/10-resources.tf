module "ssh-key" {
  source      = "../../modules/ssh-key/"
  algo_config = "${local.algo_config}"
}

module "tls" {
  source         = "../../modules/tls/"
  algo_config    = "${local.algo_config}"
  vpn_users      = "${var.vpn_users}"
  components     = "${var.components}"
  server_address = "${module.cloud-digitalocean.server_address}"
}

module "user-data" {
  source                     = "../../modules/user-data/"
  vpn_users                  = "${var.vpn_users}"
  components                 = "${var.components}"
  unmanaged                  = "${var.unmanaged}"
  clients_public_key_openssh = "${module.tls.clients_public_key_openssh}"
  ipv6                       = "${module.cloud-digitalocean.ipv6}"

  # config
  max_mss              = "${var.max_mss}"
  BetweenClients_DROP  = "${var.BetweenClients_DROP}"
  system_upgrade       = "${var.system_upgrade}"
  strongswan_log_level = "${var.strongswan_log_level}"
  adblock_lists        = "${var.adblock_lists}"
  unattended_reboot    = "${var.unattended_reboot}"
  dnscrypt_servers     = "${var.dnscrypt_servers}"
  ipv4_dns_servers     = "${var.ipv4_dns_servers}"
  ipv6_dns_servers     = "${var.ipv6_dns_servers}"
  local_service_ip     = "${var.local_service_ip}"
}

module "cloud-digitalocean" {
  source             = "../../modules/cloud-digitalocean/"
  region             = "${var.region}"
  algo_name          = "${var.algo_name}"
  public_key_openssh = "${module.ssh-key.public_key_openssh}"
  user_data          = "${module.user-data.template_cloudinit_config}"
}

module "configs" {
  source             = "../../modules/configs/"
  algo_config        = "${local.algo_config}"
  vpn_users          = "${var.vpn_users}"
  components         = "${var.components}"
  ipv6               = "${module.cloud-digitalocean.ipv6}"
  server_address     = "${local.server_address}"
  client_p12_pass    = "${module.tls.client_p12_pass}"
  clients_p12_base64 = "${module.tls.clients_p12_base64}"
  ca_cert            = "${module.tls.ca_cert}"
  server_cert        = "${module.tls.server_cert}"
  server_key         = "${module.tls.server_key}"
  crl                = "${module.tls.crl}"
  ssh_user           = "${module.cloud-digitalocean.ssh_user}"
  private_key        = "${module.ssh-key.private_key_pem}"
  server_id          = "${module.cloud-digitalocean.server_id}"
  wg_users_private   = "${module.user-data.wg_users_private}"
  wg_users_public    = "${module.user-data.wg_users_public}"
  local_service_ip   = "${module.user-data.local_service_ip}"
  wireguard_network  = "${module.user-data.wireguard_network}"
  ondemand           = "${var.ondemand}"
}
