locals {
  algo_config_tmp = ".tmp/.algo-configs-test}/"
  algo_config     = "configs/${local.algo_config_tmp}"
}

resource "null_resource" "config" {
  provisioner "local-exec" {
    command = "mkdir -p '${local.algo_config}'"
  }
}

resource "null_resource" "config-link" {
  provisioner "local-exec" {
    command     = "ln -sf '${local.algo_config_tmp}' '${module.cloud-ec2.server_address}'"
    working_dir = "configs"
  }

  provisioner "local-exec" {
    command     = "rm '${module.cloud-ec2.server_address}'"
    when        = "destroy"
    working_dir = "configs"
  }
}

resource "null_resource" "deploy_certificates" {
  triggers = {
    instance_id      = "${module.cloud-ec2.instance_id}"
  }

  connection {
    host        = "${module.cloud-ec2.server_address}"
    user        = "ubuntu"
    private_key = "${module.ssh-key.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash -c 'mkdir -p /etc/ipsec.d/{cacerts,certs,private} >/dev/null 2>&1 || true'"
    ]
  }

  provisioner "file" {
    content     = "${module.tls.ca_cert}"
    destination = "/tmp/ca.pem"
  }

  provisioner "file" {
    content     = "${module.tls.server_cert}"
    destination = "/tmp/server-cert.pem"
  }

  provisioner "file" {
    content     = "${module.tls.server_key}"
    destination = "/tmp/server-key.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/ca.pem /etc/ipsec.d/cacerts/ca.pem",
      "sudo mv /tmp/server-cert.pem /etc/ipsec.d/certs/server.pem",
      "sudo mv /tmp/server-key.pem /etc/ipsec.d/private/server.pem"
    ]
  }
}
