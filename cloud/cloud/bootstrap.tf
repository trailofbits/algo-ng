module "bootstrap" {
  source          = "../../modules/bootstrap/"
  server_address  = local.modules[var.config.cloud].0.server_address
  ssh_user        = local.modules[var.config.cloud].0.ssh_user
  ssh_private_key = tls_private_key.ssh.private_key_pem
  config          = var.config

  triggers = {
    server_id = local.modules[var.config.cloud].0.server_id
  }
}
