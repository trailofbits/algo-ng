module "bootstrap" {
  source = "../../modules/bootstrap/"
  config = merge(var.config, {
    cloud-local = {
      ssh_private_key = tls_private_key.ssh.private_key_pem
      server_address  = local.modules[var.config.cloud].0.server_address
      ssh_user        = local.modules[var.config.cloud].0.ssh_user
      ipv6            = local.modules[var.config.cloud].0.ipv6
    }
  })

  triggers = {
    server_id = local.modules[var.config.cloud].0.server_id
  }
}
