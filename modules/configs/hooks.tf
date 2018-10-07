resource "null_resource" "deploy_crl" {
  triggers    = {
    users = "${join(",", var.vpn_users)}"
    # crl   = "${md5(var.crl)}"
  }

  connection {
    host        = "${var.server_address}"
    user        = "${var.ssh_user}"
    private_key = "${var.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "bash -c 'mkdir -p /etc/ipsec.d/crls >/dev/null 2>&1 || true'"
    ]
  }

  provisioner "file" {
    content     = "${var.crl}"
    destination = "/etc/ipsec.d/crls/algo.root.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl status strongswan 2>&1 >/dev/null&& sh -c 'ipsec rereadcrls; ipsec purgecrls' || true",
      "touch /root/.terraform_complete"
    ]
  }
}

resource "null_resource" "deploy_certificates" {
  triggers = {
    server_id   = "${var.server_id}"
    ca_cert     = "${var.ca_cert}"
    server_cert = "${var.server_cert}"
    server_key  = "${var.server_key}"
  }

  connection {
    host        = "${var.server_address}"
    user        = "${var.ssh_user}"
    private_key = "${var.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "bash -c 'mkdir -p /etc/ipsec.d/{cacerts,certs,private} >/dev/null 2>&1 || true'"
    ]
  }

  provisioner "file" {
    content     = "${var.ca_cert}"
    destination = "/etc/ipsec.d/cacerts/ca.pem"
  }

  provisioner "file" {
    content     = "${var.server_cert}"
    destination = "/etc/ipsec.d/certs/server.pem"
  }

  provisioner "file" {
    content     = "${var.server_key}"
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

resource "null_resource" "get_wireguard_server_pubkey" {
  triggers {
    users     = "${join(",", var.vpn_users)}"
    server_id = "${var.server_id}"
    test = 1
  }

  connection {
    host        = "${var.server_address}"
    user        = "${var.ssh_user}"
    private_key = "${var.private_key}"
  }
  
  provisioner "remote-exec" {
    inline = [
      "until test -f /tmp/.wg-server.pub; do sleep 5; done"
    ]
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i '${var.algo_config}/algo.pem' ${var.ssh_user}@${var.server_address}:/tmp/.wg-server.pub ${var.algo_config}/.wg-server.pub"
  }
}

data "local_file" "wg_server_pubkey" {
  depends_on  = ["null_resource.get_wireguard_server_pubkey"]
  filename  = "${var.algo_config}/.wg-server.pub"
}

resource "null_resource" "wait-until-deploy-finished" {
  depends_on  = [
    "null_resource.deploy_certificates",
    "null_resource.deploy_crl",
    "null_resource.get_wireguard_server_pubkey"
  ]

  triggers {
    server_id   = "${var.server_id}"
  }

  connection {
    host        = "${var.server_address}"
    user        = "${var.ssh_user}"
    private_key = "${var.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "until test -f /tmp/booted; do sleep 5; done"
    ]
  }
}
