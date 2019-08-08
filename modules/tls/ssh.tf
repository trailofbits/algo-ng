resource "tls_private_key" "algo_ssh" {
  algorithm = var.ssh_key_algorithm
  rsa_bits  = var.ssh_key_rsa_bits
}

resource "local_file" "ssh_private_key" {
  content  = tls_private_key.algo_ssh.private_key_pem
  filename = "${var.algo_config}/algo.pem"

  provisioner "local-exec" {
    command = "chmod 0600 ${var.algo_config}/algo.pem"
  }
}
