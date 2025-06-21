locals {
  vpn_users_map = { for u in var.algo_config.users : u => u }

  ipsec_count  = var.algo_config.ipsec.enabled ? 1 : 0
  ipsec_users  = var.algo_config.ipsec.enabled ? local.vpn_users_map : {}
  ipsec_config = var.resources.ipsec_config

  ssh_tunneling_users  = var.algo_config.ssh_tunneling.enabled ? local.vpn_users_map : {}
  ssh_tunneling_config = var.resources.ssh_tunneling

  wireguard_users  = var.algo_config.wireguard.enabled ? local.vpn_users_map : {}
  wireguard_config = var.resources.wireguard_config
}
