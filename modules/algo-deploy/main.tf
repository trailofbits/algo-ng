variable "server_address" {}
variable "vpn_users" {}
variable "ca_password" {}
variable "algo_ssh_private" {}
variable "private_key_pem" {}
variable "DEPLOY_vpn" {}
variable "DEPLOY_dns_adblocking" {}
variable "DEPLOY_ssh_tunneling" {}
variable "DEPLOY_security" {}
variable "ssh_user" { default = "root" }

resource "null_resource" "deploy" {
  triggers {
    server_address      = "${chomp(var.server_address)}"
    vpn_users           = "${var.vpn_users}"
    deploy_script_sha1  = "${sha1(file("${path.module}/scripts/deploy.sh"))}"
  }

  connection {
    type        = "ssh"
    user        = "${var.ssh_user}"
    host        = "${var.server_address}"
    private_key = "${var.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = [ "# Connected!" ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p  /opt/algo/",
      "sudo chown -R ${var.ssh_user}: /opt/algo/"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/playbooks"
    destination = "/opt/algo/playbooks"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/deploy.sh"
    destination = "/opt/algo/algo.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash -x /opt/algo/algo.sh '${var.vpn_users}' '${var.ca_password == "" ? "false" : var.ca_password}' '${var.server_address}' '${var.DEPLOY_vpn == 1 ? "vpn" : "_null"},${var.DEPLOY_dns_adblocking == 1 ? "dns_adblocking" : "_null"},${var.DEPLOY_ssh_tunneling == 1 ? "ssh_tunneling" : "_null"},${var.DEPLOY_security == 1 ? "security" : "_null"}' '${var.ssh_user}' '${var.algo_ssh_private}' | sudo tee /var/log/alog.log",
    ]
  }

  provisioner "local-exec" {
    command = "rsync --rsync-path='sudo rsync' -a -e 'ssh -i ${var.algo_ssh_private} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' ${var.ssh_user}@${var.server_address}:/opt/algo/playbooks/configs/${var.server_address}/ ./configs/${var.server_address}/"
  }
}
