locals {
  # init_config      = var.config.init.config
  # algo_config      = local.init_config.algo_config
  # local_config     = local.init_config.local_config
  # ipsec_users      = local.algo_config.ipsec.enabled ? { for u in local.algo_config.vpn_users : u => u } : {}
  # ipsec_config     = var.config.bootstrap.ipsec_config
  ssh_tunneling_users  = var.algo_config.ssh_tunneling.enabled ? { for u in var.algo_config.users : u => u } : {}
  ssh_tunneling_config = var.resources.ssh_tunneling
  wireguard_users      = var.algo_config.wireguard.enabled ? { for u in var.algo_config.users : u => u } : {}
  wireguard_config     = var.resources.wireguard_config
}
