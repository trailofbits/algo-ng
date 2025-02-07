module "cloud" {
  source      = "../../modules/clouds/ec2/"
  algo_config = local.config
  deploy_id   = local.module_init.deploy_id
  ssh_key     = local.module_init.ssh_key
  user_data   = local.module_init.user_data

  providers = {
    aws = aws.ec2
  }
}

provider "aws" {
  alias  = "ec2"
  region = local.config.clouds.ec2.region
}
