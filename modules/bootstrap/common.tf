
resource "null_resource" "common-init" {
  connection {
    type        = "ssh"
    host        = var.server_address
    port        = 22
    user        = var.ssh_user
    private_key = var.ssh_private_key
    timeout     = "30m"
  }

  triggers = var.triggers

  provisioner "remote-exec" {
    inline = [
      "bash -c 'mkdir -p /opt/algo/{scripts,configs}/{wireguard,dnscrypt-proxy,common,ssh-tunnel}'"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/scripts"
    destination = "/opt/algo/"
  }
}

resource "null_resource" "common-templates" {
  for_each = toset(fileset("${path.module}/templates/common/", "*"))

  connection {
    type        = "ssh"
    host        = var.server_address
    port        = 22
    user        = var.ssh_user
    private_key = var.ssh_private_key
    timeout     = "30m"
  }

  triggers = var.triggers

  provisioner "file" {
    content = templatefile("${path.module}/templates/common/${each.value}", merge(
      var.config, {
        local = {
          wg_server_ip   = local.wg_server_ip
          wg_port_actual = var.wg_port_actual
          wg_ports_avoid = var.wg_ports_avoid
          subnets        = concat([var.config.wireguard.ipv4])
        }
      }
    ))
    destination = "/opt/algo/configs/common/${each.value}"
  }

  depends_on = [
    null_resource.common-init
  ]
}

resource "null_resource" "common" {
  connection {
    type        = "ssh"
    host        = var.server_address
    port        = 22
    user        = var.ssh_user
    private_key = var.ssh_private_key
    timeout     = "30m"
  }

  triggers = var.triggers

  provisioner "remote-exec" {
    inline = [
      "bash /opt/algo/scripts/common.sh"
    ]
  }

  depends_on = [
    null_resource.common-templates
  ]
}
