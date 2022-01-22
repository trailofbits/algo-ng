module "bootstrap" {
  source = "./modules/bootstrap/"
  config = merge(var.config, {
    local = {
      cloud           = var.config.clouds[var.config.cloud]
      ssh_private_key = tls_private_key.ssh.private_key_pem
      server_address  = local.modules[var.config.cloud].0.server_address
      ssh_user        = local.modules[var.config.cloud].0.ssh_user
    }
  })

  triggers = {
    server_id = local.modules[var.config.cloud].0.server_id
  }
}

module "local-configs" {
  source           = "./modules/local-configs/"
  algo_config      = local.algo_config
  ssh_keys         = module.bootstrap.ssh_keys
  wireguard_config = module.bootstrap.wireguard_config

  config = merge(var.config, {
    local = {
      cloud          = var.config.clouds[var.config.cloud]
      server_address = local.modules[var.config.cloud].0.server_address
    }
  })
}
