locals {
  ssh_tunneling = {
    ssh_keys  = var.pki.ssh.public_keys
    vpn_users = var.vpn_users
  }
}
