output "resources" {
  value = {
    wireguard_config = {
      ip_seeds = random_integer.ip_user_seed

      peers = local.wg_peers_ip

      keys = {
        clients   = x25519_private_key.wg_client
        peers_psk = x25519_private_key.wg_peers_psk
        server    = try(x25519_private_key.wg_server.0, null)
      }

      server_ip = local.wg_server_ip
    }

    ssh_tunneling = tls_private_key.ssh
  }
}
