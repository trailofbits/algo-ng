module "bootstrap" {
  source = "../../modules/bootstrap/"
  config = merge(var.config, {
    local = {
      cloud           = var.config.clouds[local.cloud_name]
      ssh_private_key = local.cloud_name == "local-server" ? file(var.config.clouds[local.cloud_name].ssh_private_key) : tls_private_key.ssh.private_key_pem
      server_address  = local.cloud_module.server_address
      ssh_user        = local.cloud_module.ssh_user
    }
  })

  triggers = {
    server_id = local.cloud_module.server_id
  }
}

module "local-configs" {
  source           = "../../modules/local-configs/"
  algo_config      = local.algo_config
  ssh_keys         = module.bootstrap.ssh_keys
  wireguard_config = module.bootstrap.wireguard_config

  config = merge(var.config, {
    local = {
      cloud          = var.config.clouds[local.cloud_name]
      server_address = local.cloud_module.server_address
    }
  })
}
