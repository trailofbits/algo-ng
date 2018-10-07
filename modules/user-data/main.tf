provider "template" { version = "~> 1.0" }

data "template_file" "common" {
  template = "${file("${path.module}/cloud-init/001-common.yml")}"
  vars {
    local_service_ip = "${var.local_service_ip}"
    rules.v4         = "${jsonencode(data.template_file.iptables-v4.rendered)}"
    system_upgrade   = "${var.system_upgrade == 1 ? "true" : "false"}"
  }
}

#
# Generate cloud-init
#

data "template_cloudinit_config" "cloud_init" {
  gzip          = "${var.gzip}"
  base64_encode = "${var.base64_encode}"

  part {
    filename     = "common"
    content      = "${data.template_file.common.rendered}"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename     = "ssh_tunneling"
    content      = "${lookup(var.components, "ssh_tunneling") == 0 ? "" : "${data.template_file.ssh_tunneling.rendered}\nusers:\n${join("\n", data.template_file.ssh_tunneling-users.*.rendered)}"}"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename     = "strongswan"
    content      = "${lookup(var.components, "ipsec") == 0 ? "" : "${data.template_file.strongswan.rendered}"}"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename     = "wireguard"
    content      = "${lookup(var.components, "wireguard") == 0 ? "" : "${data.template_file.wireguard.rendered}"}"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename     = "dns_encryption"
    content      = "${lookup(var.components, "dns_encryption") == 0 ? "" : "${data.template_file.dns_encryption.rendered}"}"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename     = "dns_adblocking"
    content      = "${lookup(var.components, "dns_adblocking") == 0 ? "" : "${data.template_file.dns_adblocking.rendered}"}"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename     = "end"
    content      = "${data.template_file.end.rendered}"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
}

locals {
  unmanaged = "until test -f /root/.terraform_complete; do echo 'Waiting for terraform to complete..'; sleep 5 ; done && systemctl stop sshd ; systemctl disable sshd"
}

data "template_file" "end" {
  template = "${file("${path.module}/cloud-init/099-end.yml")}"
  vars {
    additional_tasks = "${var.unmanaged == 1 ? "${local.unmanaged}" : "true"}"
  }
}
