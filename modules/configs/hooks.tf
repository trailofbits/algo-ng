resource "null_resource" "wait-until-deploy-finished" {
  triggers = {
    server_id = var.server_id
  }

  connection {
    host        = var.server_address
    user        = var.ssh_user
    private_key = var.private_key
  }

  provisioner "remote-exec" {
    inline = [
      "until test -f /tmp/booted; do sleep 5; done",
    ]
  }
}

data "external" "wg-server-pub" {
  depends_on = [null_resource.wait-until-deploy-finished]

  program = [
    "${path.module}/external/read-file-ssh.sh",
    "${var.ssh_user}@${var.server_address}",
    "${var.algo_config}/algo.pem",
    "/etc/wireguard/.wg-server.pub",
  ]
}
