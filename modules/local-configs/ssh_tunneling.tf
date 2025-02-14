resource "local_sensitive_file" "ssh_tunneling_private_keys" {
  for_each             = local.ssh_tunneling_users
  content              = local.ssh_tunneling_config[each.key].private_key_openssh
  filename             = "${var.local_path}/ssh_tunneling/${each.key}.pem"
  file_permission      = "0600"
  directory_permission = "0700"
}

resource "local_file" "ssh_tunneling_ssh_config" {
  for_each = local.ssh_tunneling_users

  content = templatefile("${path.module}/templates/ssh_config", {
    "server_address" = var.cloud_config.server_ip
    "user"           = each.key
  })

  filename             = "${var.local_path}/ssh_tunneling/${each.key}.ssh_config"
  file_permission      = "0600"
  directory_permission = "0700"
}
