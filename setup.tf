
locals {
  algo_config = "${path.cwd}/configs/${var.config.cloud}/${terraform.workspace}"

  modules = {
    digitalocean = module.digitalocean
    # ec2          = module.ec2
    # gce          = module.gce
    # azure        = module.azure
  }
}
