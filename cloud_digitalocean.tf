variable "do_token" {
  description = "Enter your API token. The token must have read and write permissions (https://cloud.digitalocean.com/settings/api/tokens):"
  default = ""
}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_ssh_key" "algo" {
  count      = "${var.provider == "digitalocean" ? 1 : 0}"
  name       = "${var.algo_name}"
  public_key = "${tls_private_key.algo_ssh.public_key_openssh}"
}

resource "digitalocean_droplet" "algo" {
  count     = "${var.provider == "digitalocean" ? 1 : 0}"
  name      = "${var.algo_name}"
  image     = "${var.image["digitalocean"]}"
  region    = "${var.region["digitalocean"]}"
  size      = "${var.size["digitalocean"]}"
  ipv6      = true
  user_data = "${data.template_cloudinit_config.cloud_init.rendered}"
  ssh_keys  = [
    "${digitalocean_ssh_key.algo.id}"
  ]
}

module "algo-deploy" {
  source                   = "./modules/algo-deploy"
  server_address           = "${digitalocean_droplet.algo.ipv4_address}"
  vpn_users                = "${var.vpn_users}"
  ca_password              = "${var.ca_password}"
  also_ssh_private         = "${var.also_ssh_private}"
  private_key_pem          = "${tls_private_key.algo_ssh.private_key_pem}"
  ipv6                     = true
  DEPLOY_vpn               = "${var.components["vpn"]}"
  DEPLOY_dns_adblocking    = "${var.components["dns_adblocking"]}"
  DEPLOY_ssh_tunneling     = "${var.components["ssh_tunneling"]}"
  DEPLOY_security          = "${var.components["security"]}"
}

output "INSTANCE" {
  value = "${digitalocean_droplet.algo.ipv4_address}"
}

output "CONFIGS" {
  value = "${path.module}/configs/${digitalocean_droplet.algo.ipv4_address}/"
}
