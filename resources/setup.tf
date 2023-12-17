
locals {
  algo_config = "${path.cwd}/configs/${local.cloud_name}/${terraform.workspace}"

  cloud-config = {
    cloud           = var.config.clouds[local.cloud_name]
    algo_name       = "algo-${terraform.workspace}"
    ssh_public_key  = tls_private_key.ssh.public_key_openssh
    ssh_private_key = tls_private_key.ssh.private_key_pem
    tfvars          = var.config
    user_data       = module.user-data.output
    deploy_id       = random_string.deploy_id.result
  }
}

resource "random_string" "deploy_id" {
  length      = 4
  special     = false
  lower       = true
  upper       = false
  min_numeric = 2
}
