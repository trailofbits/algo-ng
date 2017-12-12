variable "do_token" {
  description = "Enter your API token. The token must have read and write permissions (https://cloud.digitalocean.com/settings/api/tokens):"
}

variable "do_image" {
  default = "ubuntu-16-04-x64"
}

variable "do_size" {
  default = "512mb"
}

variable "do_region" {
  default = "ams3"
}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_ssh_key" "algo" {
  count      = "${var.cloud_digitalocean == "true" ? 1 : 0}"
  name       = "algo-ng"
  public_key = "${tls_private_key.algo_ssh.public_key_openssh}"
}

resource "digitalocean_droplet" "algo" {
  count     = "${var.cloud_digitalocean == "true" ? 1 : 0}"
  lifecycle = {
    ignore_changes = [
      "user_data"
    ]
  }
  image     = "ubuntu-16-04-x64"
  name      = "algo-ng"
  region    = "ams3"
  size      = "512mb"
  ipv6      = true
  user_data = "${data.template_cloudinit_config.cloud_init.rendered}"
  ssh_keys  = [
    "${digitalocean_ssh_key.algo.id}"
  ]
}

module "algo-deploy" {
  source            = "./modules/algo-deploy"
  server_address    = "${digitalocean_droplet.algo.ipv4_address}"
  vpn_users         = "${var.vpn_users}"
  ca_password       = "${var.ca_password}"
  config_path       = "${var.config_path}"
  also_ssh_private  = "${var.also_ssh_private}"
  private_key_pem   = "${tls_private_key.algo_ssh.private_key_pem}"
  ipv6              = true
}

output "INSTANCE" {
  value = "${digitalocean_droplet.algo.ipv4_address}"
}

output "CONFIGS" {
  value = "${path.module}/configs/${digitalocean_droplet.algo.ipv4_address}/"
}
