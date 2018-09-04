data "template_file" "common" {
  template = "${file("${path.module}/cloud-init/001-common.yml")}"
}

data "template_file" "strongswan" {
  template = "${file("${path.module}/cloud-init/010-strongswan.yml")}"
  vars {
    strongswan.conf = "${jsonencode(file("${path.module}/files/strongswan.conf"))}"
    ipsec.conf      = "${jsonencode(file("${path.module}/files/ipsec.conf"))}"
  }
}

data "template_file" "dns_encryption" {
  template = "${file("${path.module}/cloud-init/011-dns_encryption.yml")}"
  vars {
    apparmor_dnscrypt-proxy = "${jsonencode(file("${path.module}/files/apparmor/usr.sbin.dnscrypt-proxy"))}"
    ip-blacklist.txt        = "${jsonencode(file("${path.module}/files/ip-blacklist.txt"))}"
    dnscrypt-proxy.toml     = "${jsonencode(file("${path.module}/files/dnscrypt-proxy.toml"))}"
  }
}

data "template_file" "dns_adblocking" {
  template = "${file("${path.module}/cloud-init/015-dns_adblocking.yml")}"
  vars {
    apparmor_dnsmasq  = "${jsonencode(file("${path.module}/files/apparmor/usr.sbin.dnsmasq"))}"
    dnsmasq.conf      = "${jsonencode(file("${path.module}/files/dnsmasq.conf"))}"
    adblock.sh        = "${jsonencode(file("${path.module}/files/adblock.sh"))}"
  }
}

data "template_file" "ssh_tunneling" {
  template = "${file("${path.module}/cloud-init/012-ssh_tunneling.yml")}"
}

data "template_file" "ssh_tunneling-users" {
  count    = "${length(var.vpn_users)}"
  template = "${file("${path.module}/cloud-init/012-ssh_tunneling-users.yml")}"
  vars {
    user                = "${element(var.vpn_users, count.index)}"
    public_key_openssh  = "${element(var.clients_public_key_openssh, count.index)}"
    # group               = "${lookup(var.vpn_users, count.index+1) == 0 ? "algo_disabled" : "algo"}"
  }
}


data "template_file" "end" {
  template = "${file("${path.module}/cloud-init/099-end.yml")}"
}

data "template_cloudinit_config" "cloud_init" {
  gzip          = false
  base64_encode = false

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
