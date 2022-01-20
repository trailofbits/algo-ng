resource "tls_private_key" "ssh" {
  provider  = tls
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "ssh_private_key" {
  sensitive_content    = tls_private_key.ssh.private_key_pem
  filename             = "${local.algo_config}/algo.pem"
  file_permission      = "0600"
  directory_permission = "0700"
}
