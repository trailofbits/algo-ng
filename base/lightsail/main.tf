module "lightsail" {
  source = "../../modules/cloud-lightsail/"
  config = local.cloud-config

  providers = {
    aws = aws.lightsail
  }
}

provider "aws" {
  alias  = "lightsail"
  region = replace(var.config.clouds.lightsail.availability_zone, "/[a-z]$/", "")
}

locals {
  cloud_module = module.lightsail
  cloud_name   = "lightsail"
}
