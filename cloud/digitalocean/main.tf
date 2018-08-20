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

module "user-data" {
  source = "../../modules/user-data/"
}

# module "cloud-digitalocean" {
#   source              = "../../modules/cloud-digitalocean/"
#   image               = "${var.image["digitalocean"]}"
#   size                = "${var.size["digitalocean"]}"
#   region              = "${var.region}"
#   public_key_openssh  = "${module.main.public_key_openssh}"
#   user_data           = "${module.user-data.template_cloudinit_config}"
#   algo_name           = "${var.algo_name}"
# }

module "tls" {
  source            = "../../modules/tls/"
  server_address    = "8.8.8.8"
  vpn_users         = "${var.vpn_users}"
  # algo_config       = "${local.algo_config}/8.8.8.8/"
  openssl_config    = "${path.cwd}/configs/openssl.cnf"
}

# module "algo-deploy" {
#   source                   = "../../modules/algo-deploy/"
#   algo_config              = "${local.algo_config}/${module.cloud-digitalocean.server_address}"
#   vpn_users                = ["${var.vpn_users}"]
#   algo_ssh_private_pem     = "${module.main.private_key_pem}"
#   DEPLOY_dns_adblocking    = "${var.components["dns_adblocking"]}"
#   DEPLOY_ssh_tunneling     = "${var.components["ssh_tunneling"]}"
#   DEPLOY_security          = "${var.components["security"]}"
#   server_address           = "${module.cloud-digitalocean.server_address}"
#   ca_cert                  = "${module.tls.ca_cert}"
#   server_cert              = "${module.tls.server_cert}"
#   server_key               = "${module.tls.server_key}"
#   crl                      = "${module.tls.crl}"
# }

# output "Configuration" {
#   value = "${local.algo_config}"
# }
