locals {
  pki = {
    wireguard = tls_x25519.wg_client

    # ssh = {
    #   public_keys  = tls_private_key.client.*.public_key_openssh
    #   private_keys = tls_private_key.client.*.private_key_pem
    # }
  }
}

output "pki" {
  value = local.pki
}

output "ssh_public_key" {
  value = tls_private_key.algo_ssh.public_key_openssh
}

output "ssh_private_key" {
  value = tls_private_key.algo_ssh.private_key_pem
}
