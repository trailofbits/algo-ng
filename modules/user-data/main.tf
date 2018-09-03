data "template_file" "common" {
  template = "${file("${path.module}/cloud-init/001-common.yml")}"
}

data "template_file" "strongswan" {
  template = "${file("${path.module}/cloud-init/010-strongswan.yml")}"
  vars {
    CA_CERT         = "${jsonencode(var.CA_CERT)}"
    SERVER_CERT     = "${jsonencode(var.SERVER_CERT)}"
    SERVER_KEY      = "${jsonencode(var.SERVER_KEY)}"
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
    filename     = "strongswan"
    content      = "${data.template_file.strongswan.rendered}"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename     = "dns_encryption"
    content      = "${data.template_file.dns_encryption.rendered}"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename     = "dns_adblocking"
    content      = "${data.template_file.dns_adblocking.rendered}"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }

  part {
    filename     = "end"
    content      = "${data.template_file.end.rendered}"
    merge_type   = "list(append)+dict(recurse_array)+str()"
  }
}
