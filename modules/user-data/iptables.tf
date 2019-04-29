data "template_file" "iptables-v4" {
  template = file("${path.module}/files/iptables/rules.v4")

  vars = {
    mss_fix             = var.max_mss >= 1000 ? "-A FORWARD -s ${var.ipsec_network["ipv4"]},${var.wireguard_network["ipv4"]} -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss ${var.max_mss}" : ""
    wireguard_port      = var.wireguard_network["port"]
    wireguard_network   = var.wireguard_network["ipv4"]
    ipsec_network       = var.ipsec_network["ipv4"]
    local_service_ip    = var.local_service_ip
    BetweenClients_DROP = var.BetweenClients_DROP == 1 ? "DROP" : "ACCEPT"
  }
}

data "template_file" "iptables-v6" {
  template = file("${path.module}/files/iptables/rules.v6")

  vars = {
    mss_fix             = var.max_mss >= 1000 ? "-A FORWARD -s ${var.ipsec_network["ipv4"]},${var.wireguard_network["ipv4"]} -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss ${var.max_mss}" : ""
    wireguard_port      = var.wireguard_network["port"]
    wireguard_network   = var.wireguard_network["ipv6"]
    ipsec_network       = var.ipsec_network["ipv6"]
    BetweenClients_DROP = var.BetweenClients_DROP == 1 ? "DROP" : "ACCEPT"
  }
}

