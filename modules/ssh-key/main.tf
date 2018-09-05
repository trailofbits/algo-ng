provider "tls"      { version = "~> 1.2" }
provider "local"    { version = "~> 1.1" }

resource "tls_private_key" "algo_ssh" {
  algorithm   = "${var.ssh_key_algorithm}"
  rsa_bits    = "${var.ssh_key_rsa_bits}"
  ecdsa_curve = "${var.ssh_key_ecdsa_curve}"
}

resource "local_file" "ssh_private_key" {
  count       = "${var.unmanaged == 1 ? 0 : 1}"
  content     = "${tls_private_key.algo_ssh.private_key_pem}"
  filename    = "${var.algo_config}/algo.pem"

  provisioner "local-exec" {
    command = "chmod 0600 ${var.algo_config}/algo.pem"
  }
}
