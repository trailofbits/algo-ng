variable "ssh_key_algorithm" {
  default = "ECDSA"
}

variable "ssh_key_ecdsa_curve" {
  default = "P384"
}

variable "ssh_key_rsa_bits" {
  default = "2048"
}

resource "tls_private_key" "algo_ssh" {
  algorithm   = var.ssh_key_algorithm
  rsa_bits    = var.ssh_key_rsa_bits
  ecdsa_curve = var.ssh_key_ecdsa_curve
}

resource "local_file" "ssh_private_key" {
  content  = tls_private_key.algo_ssh.private_key_pem
  filename = "${var.algo_config}/algo.pem"

  provisioner "local-exec" {
    command = "chmod 0600 ${var.algo_config}/algo.pem"
  }
}

output "ssh_public_key" {
  value = tls_private_key.algo_ssh.public_key_openssh
}

output "ssh_private_key" {
  value = tls_private_key.algo_ssh.private_key_pem
}
