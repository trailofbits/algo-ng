locals {
  tags = {
    App       = "AlgoVPN"
    Workspace = terraform.workspace
    DeployID  = var.config.deploy_id
  }
}

resource "scaleway_instance_ip" "main" {}

resource "scaleway_instance_server" "main" {
  name  = "algo-srv-${var.config.deploy_id}"
  image = var.config.cloud.image
  type  = var.config.cloud.size
  ip_id = scaleway_instance_ip.main.id

  enable_ipv6 = var.config.cloud.ipv6
  user_data = {
    cloud-init = base64encode(var.config.user_data.cloudinit)
  }

  tags = concat([for k, v in local.tags : "${k}:${v}"], [
    "AUTHORIZED_KEY=${chomp(replace(var.config.ssh_public_key, " ", "_"))}"
  ])
}
