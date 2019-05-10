locals {
  unmanaged = "until test -f /root/.terraform_complete; do echo 'Waiting for terraform to complete..'; sleep 5 ; done && systemctl stop sshd ; systemctl disable sshd"

  iptables = {
    common = {
      mss_fix             = var.max_mss >= 1000 ? "-A FORWARD -s ${var.ipsec_network["ipv4"]},${var.wireguard_network["ipv4"]} -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss ${var.max_mss}" : ""
      wireguard_port      = var.wireguard_network["port"]
      BetweenClients_DROP = var.BetweenClients_DROP == true ? "DROP" : "ACCEPT"
    }
    v4 = {
      wireguard_network = var.wireguard_network["ipv4"]
      ipsec_network     = var.ipsec_network["ipv4"]
      local_service_ip  = var.local_service_ip
    }

    v6 = {
      wireguard_network = var.wireguard_network["ipv6"]
      ipsec_network     = var.ipsec_network["ipv6"]
    }
  }

  common_start = {
    local_service_ip       = var.local_service_ip
    rules_v4               = templatefile("${path.module}/files/common/rules.v4", { vars = local.iptables })
    rules_v6               = templatefile("${path.module}/files/common/rules.v6", { vars = local.iptables })
    system_upgrade         = var.system_upgrade == true ? "true" : "false"
    unattended_reboot      = var.unattended_reboot["enabled"] == true ? "true" : "false"
    unattended_reboot_time = var.unattended_reboot["time"]
  }

  common_end = {
    additional_tasks = var.unmanaged == true ? local.unmanaged : "true"
  }
}
