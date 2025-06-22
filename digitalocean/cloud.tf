module "cloud" {
  source      = "../../modules/clouds/digitalocean/"
  algo_config = local.config
  deploy_id   = local.module_init.deploy_id
  ssh_key     = local.module_init.ssh_key
  user_data   = local.module_init.user_data
}
