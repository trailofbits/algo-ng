data "local_file" "wg_server_pubkey" {
  depends_on = ["null_resource.get_wireguard_server_pubkey"]
  filename   = "${var.algo_config}/.wg-server.pub"
}

resource "local_file" "wireguard" {
  count    = "${length(var.vpn_users)}"
  filename = "${var.algo_config}/${var.vpn_users[count.index]}.wg.conf"

  content = <<EOF
[Interface]
PrivateKey = ${base64encode(var.wg_users_private[count.index])}
Address = ${cidrhost(var.wireguard_network["ipv4"], 2 + count.index)}/32${var.ipv6 == 0 ? "" : ",${cidrhost(var.wireguard_network["ipv6"], 2 + count.index)}/128"}
DNS = ${var.local_service_ip}

[Peer]
PublicKey = ${chomp(data.local_file.wg_server_pubkey.content)}
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = ${var.server_address}:${var.wireguard_network["port"]}
PersistentKeepalive = 25
EOF

  provisioner "local-exec" {
    command = "chmod 0600 ${var.algo_config}/${var.vpn_users[count.index]}.wg.conf"
  }
}
