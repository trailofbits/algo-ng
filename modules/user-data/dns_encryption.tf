locals {
  dnscrypt_proxy_toml = {
    local_service_ip = var.local_service_ip
    server_names     = "'${var.dnscrypt_servers["ipv4"]}'${var.ipv6 == false ? "" : ",'${var.dnscrypt_servers["ipv6"]}'"}"
    ipv6             = var.ipv6 == true ? "true" : "false"
    cache            = var.components["dns_adblocking"] == 1 ? "false" : "true"
  }

  dns_encryption = {
    apparmor_dnscrypt-proxy = file("${path.module}/files/dns_encryption/usr.bin.dnscrypt-proxy")
    dnscrypt_proxy_toml     = templatefile("${path.module}/files/dns_encryption/dnscrypt-proxy.toml", { vars = local.dnscrypt_proxy_toml })
    ip-blacklist            = file("${path.module}/files/dns_encryption/ip-blacklist.txt")
    local_service_ip        = var.local_service_ip
  }
}
