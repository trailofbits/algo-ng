provider "tls"      { version = "~> 1.0" }
provider "local"    { version = "~> 1.0" }
provider "null"     { version = "~> 1.0" }
provider "template" { version = "~> 1.0" }

terraform {
  required_version = ">= 0.11.5"
}

resource "null_resource" "config" {
  provisioner "local-exec" {
    command = "mkdir -p ${var.algo_config}"
  }
}

resource "tls_private_key" "algo_ssh" {
  algorithm   = "RSA"
  ecdsa_curve = "2048"
}

resource "local_file" "algo_ssh_private" {
  depends_on  = [ "null_resource.config" ]
  content     = "${tls_private_key.algo_ssh.private_key_pem}"
  filename    = "${var.algo_ssh_private}"

  provisioner "local-exec" {
    command = "chmod 0600 ${var.algo_ssh_private}"
  }
}
