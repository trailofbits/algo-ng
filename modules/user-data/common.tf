locals {
  unmanaged = "until test -f /root/.terraform_complete; do echo 'Waiting for terraform to complete..'; sleep 5 ; done"

  iptables = {
    common = {
      mss_fix                      = var.config.max_mss >= 1000 ? "-A FORWARD -s ${var.config.ipsec.ipv4},${var.config.wireguard.ipv4} -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss ${var.config.max_mss}" : ""
      wireguard_port               = var.config.wireguard.port
      drop_traffic_between_clients = var.config.drop_traffic_between_clients == true ? "DROP" : "ACCEPT"
    }

    v4 = {
      wireguard_network = var.config.wireguard.ipv4
      ipsec_network     = var.config.ipsec.ipv4
      dns = [
        var.config.wireguard_dns.ipv4,
        var.config.ipsec_dns.ipv4,
      ]
    }

    v6 = {
      wireguard_network = var.config.wireguard.ipv6
      ipsec_network     = var.config.ipsec.ipv6
      dns = [
        var.config.wireguard_dns.ipv6,
        var.config.ipsec_dns.ipv6,
      ]
    }
  }

  common_start = {
    rules_v4               = templatefile("${path.module}/files/common/rules.v4", { vars = local.iptables })
    rules_v6               = templatefile("${path.module}/files/common/rules.v6", { vars = local.iptables })
    system_upgrade         = var.config.system_upgrade == true ? "true" : "false"
    unattended_reboot      = var.config.unattended_reboot.enabled == true ? "true" : "false"
    unattended_reboot_time = var.config.unattended_reboot.time
  }

  common_end = {
    additional_tasks = var.config.unmanaged == true ? local.unmanaged : "true"
  }
}
