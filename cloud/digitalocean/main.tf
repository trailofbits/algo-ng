locals {
  deployment_id     = "${timestamp()}"
  algo_config       = "${path.cwd}/configs/${var.algo_provider}_${var.region}/${var.algo_name}"
  algo_ssh_private  = "${path.cwd}/configs/algo_ssh.pem"
}

module "main" {
  source            = "../../modules/main/"
  algo_config       = "${local.algo_config}"
  algo_ssh_private  = "${local.algo_ssh_private}"
}

module "tls" {
  source            = "../../modules/tls/"
  server_address    = "${module.cloud-digitalocean.server_address}"
  vpn_users         = "${var.vpn_users}"
  algo_config       = "${local.algo_config}"
}

module "user-data" {
  source                      = "../../modules/user-data/"
  vpn_users                   = "${var.vpn_users}"
  clients_public_key_openssh  = "${module.tls.clients_public_key_openssh}"
  components                  = "${var.components}"
}

module "cloud-digitalocean" {
  source              = "../../modules/cloud-digitalocean/"
  image               = "${var.image["digitalocean"]}"
  size                = "${var.size["digitalocean"]}"
  region              = "${var.region}"
  public_key_openssh  = "${module.main.public_key_openssh}"
  private_key_pem     = "${module.main.private_key_pem}"
  user_data           = "${module.user-data.template_cloudinit_config}"
  algo_name           = "${var.algo_name}"
  ca_cert             = "${module.tls.ca_cert}"
  server_cert         = "${module.tls.server_cert}"
  server_key          = "${module.tls.server_key}"
}

output "Configuration" {
  value = "${local.algo_config}"
}

output "server_address" {
  value = "${module.cloud-digitalocean.server_address}"
}
