resource "random_string" "wg_server" {
  length  = 32
  special = true
}

data "template_file" "wireguard_interface" {
  template =<<EOF
[Interface]
Address   = ${cidrhost(var.wireguard_network["ipv4"], 1)}${var.ipv6 == 0 ? "" : ",${cidrhost(var.wireguard_network["ipv6"], 1)}"}
ListenPort = ${var.wireguard_network["port"]}
PrivateKey = ${base64encode(random_string.wg_server.result)}
SaveConfig = false
EOF
}

data "template_file" "wireguard_peer" {
  count = "${length(var.vpn_users)}"
  template =<<EOF
[Peer]
# ${var.vpn_users[count.index]}
PublicKey = ::${var.vpn_users[count.index]}::
AllowedIPs = ${cidrhost(var.wireguard_network["ipv4"], 2 + count.index)}/32${var.ipv6 == 0 ? "" : ",${cidrhost(var.wireguard_network["ipv6"], 2 + count.index)}/128"}
EOF
}

resource "random_string" "wg_user" {
  count   = "${length(var.vpn_users)}"
  length  = 32
  special = true
}

data "template_file" "wireguard_peer_pubkey_configure" {
  count = "${length(var.vpn_users)}"
  template =<<EOF
${count.index == 0 ? "set -x" : ":"}
PUBKEY=$(wg pubkey <<< '${base64encode(random_string.wg_user.*.result[count.index])}')
sed s~::${var.vpn_users[count.index]}::~$PUBKEY~ -i /etc/wireguard/wg0.conf
${count.index+1 == length(var.vpn_users) ? "systemctl restart wg-quick@wg0" : "true"}
wg pubkey <<< '${base64encode(random_string.wg_server.result)}' > /tmp/.wg-server.pub
EOF
}

data "template_file" "wireguard_server" {
  template =<<EOF
${data.template_file.wireguard_interface.rendered}
${join("\n", data.template_file.wireguard_peer.*.rendered)}
EOF
}

data "template_file" "wireguard" {
  template = "${file("${path.module}/cloud-init/020-wireguard.yml")}"
  vars {
    wg0.conf = "${jsonencode(data.template_file.wireguard_server.rendered)}"
    wg0.sh   = "${jsonencode(join("\n", data.template_file.wireguard_peer_pubkey_configure.*.rendered))}"
  }
}
