variable "server_address" {}
variable "vpn_users" {}
variable "ca_password" {}
variable "config_path" {}
variable "also_ssh_private" {}
variable "private_key_pem" {}
variable "ipv6" {}

resource "null_resource" "deploy" {
  triggers {
    vpn_users           = "${var.vpn_users}"
    deploy_script_sha1  = "${sha1(file("${path.module}/scripts/deploy.sh"))}"
  }

  connection {
    type        = "ssh"
    host        = "${var.server_address}"
    private_key = "${var.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = [ "# Connected!" ]
  }

  provisioner "file" {
    source      = "${path.module}/scripts/deploy.sh"
    destination = "/opt/algo.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash -x /opt/algo.sh '${var.vpn_users}' '${var.ca_password}' ",
    ]
  }

  provisioner "local-exec" {
    command = "rsync -a -e 'ssh -i ${var.also_ssh_private} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' root@${var.server_address}:${var.config_path}/${var.server_address}/ ./configs/${var.server_address}/"
  }
}
