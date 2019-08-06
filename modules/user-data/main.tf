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
    content    = var.config.ssh_tunneling ? templatefile("${path.module}/files/ssh_tunneling/cloud-init.yml", { vars = local.ssh_tunneling }) : ""
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename   = "strongswan"
    content    = var.config.ipsec.enabled ? templatefile("${path.module}/files/strongswan/cloud-init.yml", { vars = local.strongswan }) : ""
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename   = "wireguard"
    content    = var.config.wireguard.enabled ? templatefile("${path.module}/files/wireguard/cloud-init.yml", { vars = local.wireguard }) : ""
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename   = "dns"
    content    = var.config.dns.encryption.enabled ? templatefile("${path.module}/files/dns/cloud-init.yml", { vars = local.dns.encryption }) : ""
    merge_type = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename   = "common_end"
    content    = templatefile("${path.module}/files/common/099-cloud-init-end.yml", { vars = local.common_end })
    merge_type = "list(append)+dict(recurse_array)+str()"
  }
}
