data "template_file" "dnscrypt-proxy" {
  template = file("${path.module}/files/dnscrypt-proxy.toml")

  vars = {
    local_service_ip = var.local_service_ip
    server_names     = "'${var.dnscrypt_servers["ipv4"]}'${var.ipv6 == 0 ? "" : ",'${var.dnscrypt_servers["ipv6"]}'"}"
    ipv6             = var.ipv6 == 1 ? "true" : "false"
    cache            = var.components["dns_adblocking"] == 1 ? "false" : "true"
  }
}

data "template_file" "dns_encryption" {
  template = file("${path.module}/cloud-init/011-dns_encryption.yml")

  vars = {
    apparmor_dnscrypt-proxy = jsonencode(
      file("${path.module}/files/apparmor/usr.sbin.dnscrypt-proxy"),
    )
    ip-blacklist    = jsonencode(file("${path.module}/files/ip-blacklist.txt"))
    dnscrypt-proxy = jsonencode(data.template_file.dnscrypt-proxy.rendered)
    local_service_ip    = var.local_service_ip
  }
}
