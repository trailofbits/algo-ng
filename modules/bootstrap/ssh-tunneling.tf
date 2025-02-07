locals {
  ssh_tunnel_users = var.algo_config.ssh_tunneling.enabled ? local.users : {}

  authorized_keys = [
    for user in local.ssh_tunnel_users : {
      user           = user
      authorized_key = tls_private_key.ssh[user].public_key_openssh
    }
  ]
}

resource "tls_private_key" "ssh" {
  for_each  = local.ssh_tunnel_users
  algorithm = "ED25519"
}

resource "null_resource" "ssh-tunnel-templates" {
  for_each = {
    for k, v in toset(fileset("${path.module}/templates/ssh-tunnel/", "*")) : k => v
    if var.algo_config.ssh_tunneling.enabled
  }

  connection {
    type        = "ssh"
    timeout     = "30m"
    port        = 22
    host        = var.cloud_config.server_ip
    user        = var.cloud_config.ssh_user
    private_key = var.ssh_key.private
  }

  triggers = merge(var.triggers,
    {
      users = md5(join(",", var.algo_config.users)),
      template = md5(base64encode(templatefile("${path.module}/templates/ssh-tunnel/${each.value}",
        {
          authorized_keys = local.authorized_keys,
          users           = var.algo_config.users
        }
      )))
    }
  )

  provisioner "file" {
    content = templatefile("${path.module}/templates/ssh-tunnel/${each.value}",
      {
        authorized_keys = local.authorized_keys,
        users           = var.algo_config.users
      }
    )
    destination = "/opt/algo/configs/ssh-tunnel/${each.value}"
  }

  depends_on = [
    null_resource.common
  ]
}

resource "null_resource" "ssh-tunnel" {
  count = var.algo_config.ssh_tunneling.enabled ? 1 : 0

  connection {
    type        = "ssh"
    timeout     = "30m"
    port        = 22
    host        = var.cloud_config.server_ip
    user        = var.cloud_config.ssh_user
    private_key = var.ssh_key.private
  }

  triggers = merge(var.triggers, {
    users     = md5(join(",", var.algo_config.users))
    templates = md5(jsonencode({ for k, v in null_resource.ssh-tunnel-templates : k => v.id }))
    script    = md5(file("${path.module}/scripts/ssh-tunnel.sh"))
  })

  provisioner "file" {
    source      = "${path.module}/scripts/ssh-tunnel.sh"
    destination = "/opt/algo/scripts/ssh-tunnel.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /opt/algo/scripts/ssh-tunnel.sh"
    ]
  }

  depends_on = [
    null_resource.ssh-tunnel-templates
  ]
}
