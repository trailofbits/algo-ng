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
    command     = "ln -sf '${local.algo_config_tmp}' '${module.cloud-digitalocean.server_address}'"
    working_dir = "configs"
  }

  provisioner "local-exec" {
    command     = "rm '${module.cloud-digitalocean.server_address}'"
    when        = "destroy"
    working_dir = "configs"
  }
}

resource "null_resource" "deploy_certificates" {
  triggers = {
    digitalocean_droplet      = "${module.cloud-digitalocean.droplet_id}"
  }

  connection {
    host        = "${module.cloud-digitalocean.server_address}"
    user        = "root"
    private_key = "${module.ssh-key.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = [
      "bash -c 'mkdir -p /etc/ipsec.d/{cacerts,certs,private} >/dev/null 2>&1 || true'"
    ]
  }

  provisioner "file" {
    content     = "${module.tls.ca_cert}"
    destination = "/etc/ipsec.d/cacerts/ca.pem"
  }

  provisioner "file" {
    content     = "${module.tls.server_cert}"
    destination = "/etc/ipsec.d/certs/server.pem"
  }

  provisioner "file" {
    content     = "${module.tls.server_key}"
    destination = "/etc/ipsec.d/private/server.pem"
  }
}
