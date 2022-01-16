resource "null_resource" "dnscrypt-template" {
  for_each    = {
    for k, v in toset(fileset("${path.module}/templates/dnscrypt-proxy/", "*")) : k => v
    if var.config.dns.encryption.enabled
  }

  connection {
    type        = "ssh"
    host        = var.server_address
    port        = 22
    user        = var.ssh_user
    private_key = var.ssh_private_key
    timeout     = "30m"
  }

  triggers = merge(var.triggers,
    { dns = md5(jsonencode(var.config.dns)) }
  )

  provisioner "file" {
    content     = templatefile("${path.module}/templates/dnscrypt-proxy/${each.value}", var.config)
    destination = "/opt/algo/configs/dnscrypt-proxy/${each.value}"
  }

  depends_on = [
    null_resource.common
  ]
}

resource "null_resource" "dnscrypt-script" {
  count = var.config.dns.encryption.enabled ? 1 : 0

  connection {
    type        = "ssh"
    host        = var.server_address
    port        = 22
    user        = var.ssh_user
    private_key = var.ssh_private_key
    timeout     = "30m"
  }

  triggers = merge(var.triggers,
    { dns = md5(jsonencode(var.config.dns)) }
  )

  provisioner "remote-exec" {
    inline = [
      "bash /opt/algo/scripts/dnscrypt-proxy.sh"
    ]
  }

  depends_on = [
    null_resource.dnscrypt-template,
    null_resource.wireguard-config
  ]
}
