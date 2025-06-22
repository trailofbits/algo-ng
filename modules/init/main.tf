resource "random_string" "deploy_id" {
  length      = 4
  special     = false
  lower       = true
  upper       = false
  min_numeric = 2
}

resource "random_integer" "service_ip" {
  min = 1
  max = 1048575 # random ip form 172.16.0.0/12
}

resource "tls_private_key" "ssh" {
  algorithm = "ED25519"
}

resource "local_sensitive_file" "ssh_private_key" {
  content              = tls_private_key.ssh.private_key_openssh
  filename             = "${var.local_path}/ssh.pem"
  file_permission      = "0600"
  directory_permission = "0700"
}

data "cloudinit_config" "user_data" {
  gzip          = var.gzip
  base64_encode = var.base64_encode

  part {
    filename     = "algo.sh"
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/files/user-data.sh", {})
  }
}

locals {
  service_ip = {
    ipv4 = cidrhost("172.16.0.0/12", random_integer.service_ip.result)
    ipv6 = cidrhost("fd00::1/64", random_integer.service_ip.result)
  }

  user_data = {
    cloudinit = data.cloudinit_config.user_data.rendered
    script    = file("${path.module}/files/user-data.sh")
  }
}

output "resources" {
  value = {
    ssh_key = {
      public  = tls_private_key.ssh.public_key_openssh
      private = tls_private_key.ssh.private_key_pem
    }

    deploy_id  = random_string.deploy_id.result
    user_data  = local.user_data
    service_ip = local.service_ip
  }
}
