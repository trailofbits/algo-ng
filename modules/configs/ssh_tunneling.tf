# resource "local_file" "user_ssh_private_keys" {
#   count    = var.config.ssh_tunneling ? 0 : length(var.config.vpn_users)
#   content  = var.pki.ssh.private_keys[count.index]
#   filename = "${var.algo_config}/ssh_tunneling/${var.config.vpn_users[count.index]}.pem"
# }
