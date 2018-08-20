resource "null_resource" "deploy" {
  triggers {
    server_address      = "${chomp(var.server_address)}"
    deploy_script_sha1  = "${sha1(file("${path.module}/scripts/algo.sh"))}"
  }

  connection {
    type        = "ssh"
    user        = "${var.ssh_user}"
    host        = "${var.server_address}"
    private_key = "${var.algo_ssh_private_pem}"
  }

  provisioner "remote-exec" {
    inline = [ "# Connected!" ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/algo/ssl/",
      "sudo chown -R ${var.ssh_user}: /opt/algo/"
    ]
  }

  provisioner "file" {
    content     = "${var.ca_cert}"
    destination = "/opt/algo/ssl/cacert.pem"
  }

  provisioner "file" {
    content     = "${var.server_cert}"
    destination = "/opt/algo/ssl/${var.server_address}.crt"
  }

  provisioner "file" {
    content     = "${var.server_key}"
    destination = "/opt/algo/ssl/${var.server_address}.key"
  }

  provisioner "file" {
    content     = "${var.crl}"
    destination = "/opt/algo/ssl/algo-crl.pem"
  }

  provisioner "file" {
    source      = "${path.module}/playbooks"
    destination = "/opt/algo/playbooks"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/algo.sh"
    destination = "/opt/algo/algo.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash -x /opt/algo/algo.sh '${join(",", var.vpn_users)}' '${var.server_address}' 'vpn,${var.DEPLOY_dns_adblocking == 1 ? "dns_adblocking" : "_null"},${var.DEPLOY_ssh_tunneling == 1 ? "ssh_tunneling" : "_null"},${var.DEPLOY_security == 1 ? "security" : "_null"}' | sudo tee /var/log/alog.log",
    ]
  }
}

resource "null_resource" "update-users" {
  depends_on  = ["null_resource.deploy"]
  triggers {
    vpn_users = "${join(",", var.vpn_users)}"
  }

  connection {
    type        = "ssh"
    user        = "${var.ssh_user}"
    host        = "${var.server_address}"
    private_key = "${var.algo_ssh_private_pem}"
  }

  provisioner "file" {
    source      = "${var.algo_config}/pki/crl/algo.root.pem"
    destination = "/opt/algo/ssl/algo-crl.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo ipsec rereadcrls; sudo ipsec purgecrls",
    ]
  }
}
