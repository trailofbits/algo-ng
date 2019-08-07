resource "null_resource" "wait-until-deploy-finished" {
  triggers = {
    server_id = var.server_id
  }

  connection {
    host        = var.server_address
    user        = var.ssh_user
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = [
      "until test -f /tmp/booted; do sleep 5; done",
    ]
  }
}
