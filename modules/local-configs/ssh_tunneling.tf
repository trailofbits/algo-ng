resource "local_sensitive_file" "ssh_tunneling_private_keys" {
  for_each = {
    for k, v in toset(var.config.vpn_users) : k => v
    if var.config.ssh_tunneling.enabled
  }

  content              = var.ssh_keys[each.key].private_key_pem
  filename             = "${var.algo_config}/ssh_tunneling/${each.key}.pem"
  file_permission      = "0600"
  directory_permission = "0700"
}

resource "local_file" "ssh_tunneling_ssh_config" {
  for_each = {
    for k, v in toset(var.config.vpn_users) : k => v
    if var.config.ssh_tunneling.enabled
  }

  content = templatefile("${path.module}/templates/ssh_config",
    merge(var.config, {
      "server_address" = var.config.local.server_address
      "user"           = each.key
    })
  )

  filename             = "${var.algo_config}/ssh_tunneling/${each.key}.ssh_config"
  file_permission      = "0600"
  directory_permission = "0700"
}
