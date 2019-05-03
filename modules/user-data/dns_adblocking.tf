locals {
  vars = {
    local_service_ip = var.local_service_ip
  }

  dns_adblocking = {
    apparmor_dnsmasq = file("${path.module}/files/dns_adblocking/usr.sbin.dnsmasq")
    dnsmasq_conf     = templatefile("${path.module}/files/dns_adblocking/dnsmasq.conf", { vars = local.vars })
    adblock_sh       = file("${path.module}/files/dns_adblocking/adblock.sh")
    local_service_ip = local.vars.local_service_ip
    adblock_lists    = join("\n", var.adblock_lists)
  }
}
