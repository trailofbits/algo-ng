locals {
  ipsec_conf = {
    ike                  = var.components["windows"] == true ? var.ciphers_compat["ike"] : var.ciphers["ike"]
    esp                  = var.components["windows"] == true ? var.ciphers_compat["esp"] : var.ciphers["esp"]
    strongswan_log_level = var.strongswan_log_level
    rightsourceip        = "${var.ipsec_network["ipv4"]}${var.ipv6 == false ? "" : ",${var.ipsec_network["ipv6"]}"}"
    rightdns             = var.components["dns_encryption"] == true || var.components["dns_adblocking"] == true ? var.local_service_ip : "${join(",", var.ipv4_dns_servers)}${var.ipv6 == false ? "" : ",${join(",", var.ipv6_dns_servers)}"}"
  }

  strongswan = {
    strongswan_conf = file("${path.module}/files/strongswan/strongswan.conf")
    ipsec_conf      = templatefile("${path.module}/files/strongswan/ipsec.conf", { vars = local.ipsec_conf })
    pki             = var.pki
  }
}
