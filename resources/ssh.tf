resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

resource "local_sensitive_file" "ssh_private_key" {
  content              = tls_private_key.ssh.private_key_openssh
  filename             = "${local.algo_config}/algo.pem"
  file_permission      = "0600"
  directory_permission = "0700"
}
