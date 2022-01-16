module "local-configs" {
  source           = "../../modules/local-configs/"
  config           = var.config
  algo_config      = local.algo_config
  server_address   = local.modules[var.config.cloud].0.server_address
  ssh_keys         = module.bootstrap.ssh_keys
  wireguard_config = module.bootstrap.wireguard_config
}
