provider "random"    { version = "~> 2.0" }

resource "random_id" "config" {
  byte_length = 8
}

locals {
  algo_config_tmp = ".tmp/.algo-configs-${random_id.config.hex}/"
  algo_config     = "configs/${local.algo_config_tmp}"
}

resource "null_resource" "config" {
  provisioner "local-exec" {
    command     = "mkdir -p '${local.algo_config}/keys'"
  }
}

resource "null_resource" "deploy_crl" {
  depends_on  = ["module.tls"]
  triggers    = {
    users = "${join(",", var.vpn_users)}"
  }

  connection {
    host        = "${module.cloud-digitalocean.server_address}"
    user        = "${module.cloud-digitalocean.ssh_user}"
    private_key = "${module.ssh-key.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = [
      "bash -c 'mkdir -p /etc/ipsec.d/crls >/dev/null 2>&1 || true'"
    ]
  }

  provisioner "file" {
    source      = "${module.tls.crl}"
    destination = "/etc/ipsec.d/crls/algo.root.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl status strongswan && sh -c 'ipsec rereadcrls; ipsec purgecrls' || true",
      "touch /root/.terraform_complete"
    ]
  }
}

resource "null_resource" "config-link" {
  depends_on    = ["null_resource.deploy_crl"]

  provisioner "local-exec" {
    command     = "ln -sf '${local.algo_config_tmp}' '${module.cloud-digitalocean.server_address}'"
    working_dir = "configs"
  }

  provisioner "local-exec" {
    command     = "rm '${module.cloud-digitalocean.server_address}' || true"
    when        = "destroy"
    working_dir = "configs"
  }
}

resource "null_resource" "deploy_certificates" {
  triggers = {
    server_id   = "${module.cloud-digitalocean.server_id}"
    ca_cert     = "${module.tls.ca_cert}"
    server_cert = "${module.tls.server_cert}"
    server_key  = "${module.tls.server_key}"
  }

  connection {
    host        = "${module.cloud-digitalocean.server_address}"
    user        = "${module.cloud-digitalocean.ssh_user}"
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

  provisioner "remote-exec" {
    inline = ["touch /root/.terraform_complete"]
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl status strongswan 2>&1 >/dev/null && systemctl restart strongswan || true"
    ]
  }
}
