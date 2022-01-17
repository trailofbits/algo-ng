resource "tls_private_key" "ssh" {
  for_each = {
    for k, v in toset(var.config.vpn_users) : k => v
    if var.config.ssh_tunneling.enabled
  }

  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

locals {
  authorized_keys = [
    for user in var.config.vpn_users : {
      user           = user
      authorized_key = var.config.ssh_tunneling.enabled ? tls_private_key.ssh[user].public_key_openssh : false
    }
  ]
}

resource "null_resource" "ssh-tunnel-templates" {
  for_each = {
    for k, v in toset(fileset("${path.module}/templates/ssh-tunnel/", "*")) : k => v
    if var.config.ssh_tunneling.enabled
  }

  connection {
    type        = "ssh"
    host        = var.config.cloud-local.server_address
    port        = 22
    user        = var.config.cloud-local.ssh_user
    private_key = var.config.cloud-local.ssh_private_key
    timeout     = "30m"
  }

  triggers = merge(var.triggers,
    {
      vpn_users = md5(join(",", var.config.vpn_users)),
      template = md5(base64encode(templatefile("${path.module}/templates/ssh-tunnel/${each.value}",
        merge(var.config,
        { "authorized_keys" = local.authorized_keys })
      )))
    }
  )

  provisioner "file" {
    content = templatefile("${path.module}/templates/ssh-tunnel/${each.value}",
      merge(var.config,
      { "authorized_keys" = local.authorized_keys })
    )
    destination = "/opt/algo/configs/ssh-tunnel/${each.value}"
  }

  depends_on = [
    null_resource.common
  ]
}

resource "null_resource" "ssh-tunnel" {
  count = var.config.ssh_tunneling.enabled ? 1 : 0

  connection {
    type        = "ssh"
    host        = var.config.cloud-local.server_address
    port        = 22
    user        = var.config.cloud-local.ssh_user
    private_key = var.config.cloud-local.ssh_private_key
    timeout     = "30m"
  }

  triggers = merge(var.triggers,
    {
      vpn_users = md5(join(",", var.config.vpn_users)),
      script    = md5(file("${path.module}/scripts/ssh-tunnel.sh"))
    }
  )

  provisioner "file" {
    source      = "${path.module}/scripts/ssh-tunnel.sh"
    destination = "/opt/algo/scripts/ssh-tunnel.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /opt/algo/scripts/ssh-tunnel.sh"
    ]
  }

  depends_on = [
    null_resource.ssh-tunnel-templates
  ]
}

output "ssh_keys" {
  value = tls_private_key.ssh
}
