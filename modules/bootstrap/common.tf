
resource "null_resource" "common-init" {
  connection {
    type        = "ssh"
    host        = var.config.cloud-local.server_address
    port        = 22
    user        = var.config.cloud-local.ssh_user
    private_key = var.config.cloud-local.ssh_private_key
    timeout     = "30m"
  }

  triggers = merge(var.triggers, {
    scripts = sha1(join(",", [for f in fileset("${path.module}/scripts/", "*") : filesha1("${path.module}/scripts/${f}")]))
  })

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
    host        = var.config.cloud-local.server_address
    port        = 22
    user        = var.config.cloud-local.ssh_user
    private_key = var.config.cloud-local.ssh_private_key
    timeout     = "30m"
  }

  triggers = merge(var.triggers, {
    templates = md5(file("${path.module}/templates/common/${each.value}"))
  })

  provisioner "file" {
    content = templatefile("${path.module}/templates/common/${each.value}", merge(
      var.config, {
        local = {
          wg_server_ip   = local.wg_server_ip
          wg_port_actual = var.wg_port_actual
          wg_ports_avoid = var.wg_ports_avoid

          subnets = {
            ipv4 = [var.config.wireguard.ipv4]
            ipv6 = [var.config.wireguard.ipv6]
          }
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
    host        = var.config.cloud-local.server_address
    port        = 22
    user        = var.config.cloud-local.ssh_user
    private_key = var.config.cloud-local.ssh_private_key
    timeout     = "30m"
  }

  triggers = merge(var.triggers, {
    templates = md5(jsonencode({ for k, v in null_resource.common-templates : k => v.triggers }))
    scripts   = null_resource.common-init.id
  })

  provisioner "remote-exec" {
    inline = [
      "bash /opt/algo/scripts/common.sh"
    ]
  }

  depends_on = [
    null_resource.common-templates
  ]
}
