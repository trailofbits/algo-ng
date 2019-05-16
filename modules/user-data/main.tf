data "template_cloudinit_config" "cloud_init" {
  gzip          = var.gzip
  base64_encode = var.base64_encode

  part {
    filename   = "common_start"
    content    = templatefile("${path.module}/files/common/001-cloud-init-start.yml", { vars = local.common_start })
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename   = "cloud_specific"
    content    = var.cloud_specific
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename   = "ssh_tunneling"
    content    = var.components["ssh_tunneling"] == false ? "" : templatefile("${path.module}/files/ssh_tunneling/cloud-init.yml", { vars = local.ssh_tunneling })
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename   = "strongswan"
    content    = var.components["ipsec"] == false ? "" : templatefile("${path.module}/files/strongswan/cloud-init.yml", { vars = local.strongswan })
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename   = "wireguard"
    content    = var.components["wireguard"] == false ? "" : templatefile("${path.module}/files/wireguard/cloud-init.yml", { vars = local.wireguard })
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename   = "dns_encryption"
    content    = var.components["dns_encryption"] == false ? "" : templatefile("${path.module}/files/dns_encryption/cloud-init.yml", { vars = local.dns_encryption })
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename   = "dns_adblocking"
    content    = var.components["dns_adblocking"] == false ? "" : templatefile("${path.module}/files/dns_adblocking/cloud-init.yml", { vars = local.dns_adblocking })
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename   = "common_end"
    content    = templatefile("${path.module}/files/common/099-cloud-init-end.yml", { vars = local.common_end })
    merge_type = "list(append)+dict(recurse_array)+str()"
  }
}
