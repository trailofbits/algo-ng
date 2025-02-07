resource "null_resource" "dnscrypt-template" {
  for_each = {
    for k, v in toset(fileset("${path.module}/templates/dnscrypt-proxy/", "*")) : k => v
    if var.algo_config.dns.encryption.enabled
  }

  connection {
    type        = "ssh"
    timeout     = "30m"
    port        = 22
    host        = var.cloud_config.server_ip
    user        = var.cloud_config.ssh_user
    private_key = var.ssh_key.private
  }

  triggers = merge(var.triggers, {
    dns = md5(jsonencode(var.algo_config.dns))
    template = md5(jsonencode(templatefile("${path.module}/templates/dnscrypt-proxy/${each.value}",
      {
        cloud_config = var.cloud_config
        algo_config  = var.algo_config
        service_ip   = var.init_config.service_ip
      })
    ))
  })

  provisioner "file" {
    content = templatefile("${path.module}/templates/dnscrypt-proxy/${each.value}", {
      cloud_config = var.cloud_config
      algo_config  = var.algo_config
      service_ip   = var.init_config.service_ip
    })
    destination = "/opt/algo/configs/dnscrypt-proxy/${each.value}"
  }

  depends_on = [
    null_resource.common
  ]
}

resource "null_resource" "dnscrypt-script" {
  count = var.algo_config.dns.encryption.enabled ? 1 : 0

  connection {
    type        = "ssh"
    timeout     = "30m"
    port        = 22
    host        = var.cloud_config.server_ip
    user        = var.cloud_config.ssh_user
    private_key = var.ssh_key.private
  }

  triggers = merge(var.triggers, {
    dns       = md5(jsonencode(var.algo_config.dns))
    templates = md5(jsonencode({ for k, v in null_resource.dnscrypt-template : k => v.id }))
    script    = md5(file("${path.module}/scripts/dnscrypt-proxy.sh"))
  })

  provisioner "remote-exec" {
    inline = [
      "sudo bash /opt/algo/scripts/dnscrypt-proxy.sh"
    ]
  }

  depends_on = [
    null_resource.dnscrypt-template,
    null_resource.wireguard-config
  ]
}
