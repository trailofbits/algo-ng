module "local-configs" {
  source           = "../../modules/local-configs/"
  algo_config      = local.algo_config
  ssh_keys         = module.bootstrap.ssh_keys
  wireguard_config = module.bootstrap.wireguard_config

  config = merge(var.config, {
    cloud-local = {
      server_address = local.modules[var.config.cloud].0.server_address
      ipv6           = local.modules[var.config.cloud].0.ipv6
    }
  })
}
