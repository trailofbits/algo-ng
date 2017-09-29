resource "tls_private_key" "algo_ssh" {
  algorithm   = "RSA"
  ecdsa_curve = "2048"
}

resource "local_file" "algo_ssh_private" {
    content   = "${tls_private_key.algo_ssh.private_key_pem}"
    filename  = "${var.also_ssh_private}"

    provisioner "local-exec" {
      command = "chmod 0600 ${var.also_ssh_private}"
  }
}
