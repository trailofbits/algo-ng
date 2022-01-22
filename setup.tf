
locals {
  algo_config = "${path.cwd}/configs/${var.config.cloud}/${terraform.workspace}"

  modules = {
    digitalocean = module.digitalocean
    ec2          = module.ec2
    # gce          = module.gce
    # azure        = module.azure
  }

  cloud-config = {
    cloud           = var.config.clouds[var.config.cloud]
    algo_name       = "algo-${terraform.workspace}"
    ssh_public_key  = tls_private_key.ssh.public_key_openssh
    ssh_private_key = tls_private_key.ssh.private_key_pem
    tfvars          = var.config
    user_data       = module.user-data.user_data
  }
}
