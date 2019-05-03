resource "local_file" "user_ssh_private_keys" {
  count    = var.components["ssh_tunneling"] == 0 ? 0 : length(var.vpn_users)
  content  = var.pki.ssh.private_keys[count.index]
  filename = "${var.algo_config}/ssh_tunneling/${var.vpn_users[count.index]}.pem"
}
