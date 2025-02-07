locals {
  users = { for u in var.algo_config.users : u => u }
}

resource "null_resource" "common-init" {
  connection {
    type        = "ssh"
    timeout     = "30m"
    port        = 22
    host        = var.cloud_config.server_ip
    user        = var.cloud_config.ssh_user
    private_key = var.ssh_key.private
  }

  triggers = merge(var.triggers, {
    scripts = sha1(join(",", [for f in fileset("${path.module}/scripts/", "*") : filesha1("${path.module}/scripts/${f}")]))
  })

  provisioner "remote-exec" {
    inline = [
      "sudo bash -c 'mkdir -p /opt/algo/{scripts,configs}/{strongswan,wireguard,dnscrypt-proxy,common,ssh-tunnel}'",
      "sudo bash -c 'chown -R $SUDO_USER /opt/algo'"
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
    timeout     = "30m"
    port        = 22
    host        = var.cloud_config.server_ip
    user        = var.cloud_config.ssh_user
    private_key = var.ssh_key.private
  }

  triggers = merge(var.triggers, {
    templates = md5(file("${path.module}/templates/common/${each.value}"))
  })

  provisioner "file" {
    content = templatefile("${path.module}/templates/common/${each.value}", {
      wg_server_ip   = local.wg_server_ip
      wg_port_actual = local.wg_port_actual
      wg_ports_avoid = local.wg_ports_avoid
      algo_config    = var.algo_config

      subnets = {
        ipv4 = [var.algo_config.wireguard.ipv4]
        ipv6 = [var.algo_config.wireguard.ipv6]
      }

      init = var.init_config
    })
    destination = "/opt/algo/configs/common/${each.value}"
  }

  depends_on = [
    null_resource.common-init
  ]
}

resource "null_resource" "common" {
  connection {
    type        = "ssh"
    timeout     = "30m"
    port        = 22
    host        = var.cloud_config.server_ip
    user        = var.cloud_config.ssh_user
    private_key = var.ssh_key.private
  }

  triggers = merge(var.triggers, {
    templates = md5(jsonencode({ for k, v in null_resource.common-templates : k => v.triggers }))
    script    = md5(file("${path.module}/scripts/common.sh"))
  })

  provisioner "remote-exec" {
    inline = [
      "sudo bash /opt/algo/scripts/common.sh"
    ]
  }

  depends_on = [
    null_resource.common-templates
  ]
}
