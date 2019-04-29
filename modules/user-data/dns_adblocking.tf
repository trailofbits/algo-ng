data "template_file" "dnsmasq" {
  template = file("${path.module}/files/dnsmasq.conf")

  vars = {
    local_service_ip = var.local_service_ip
  }
}

data "template_file" "dns_adblocking" {
  template = file("${path.module}/cloud-init/015-dns_adblocking.yml")

  vars = {
    apparmor_dnsmasq = jsonencode(file("${path.module}/files/apparmor/usr.sbin.dnsmasq"))
    dnsmasqConf     = jsonencode(data.template_file.dnsmasq.rendered)
    adblockSh       = jsonencode(file("${path.module}/files/adblock.sh"))
    local_service_ip = var.local_service_ip
    adblock_lists    = jsonencode(join("\n", var.adblock_lists))
  }
}
