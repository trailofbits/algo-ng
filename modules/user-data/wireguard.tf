# TODO: revise the way we generate private keys for WireGuard
# EdDSA/Ed25519 is not implemented in Terraform yet
# https://github.com/terraform-providers/terraform-provider-tls/issues/26
resource "random_string" "wg_server_private_key" {
  length  = 32
  special = true
}

resource "random_string" "wg_client_private_key" {
  count   = length(var.vpn_users)
  length  = 32
  special = true
}

locals {
  wg_server_private_key = base64encode(random_string.wg_server_private_key.result)
}

#
# wg0.conf
#

data "template_file" "wireguard_peer" {
  count = length(var.vpn_users)

  template = <<-EOF
    [Peer]
    # ${var.vpn_users[count.index]}
    PublicKey = ::${var.vpn_users[count.index]}::
    AllowedIPs = ${cidrhost(var.wireguard_network["ipv4"], 2 + count.index)}/32${var.ipv6 == 0 ? "" : ",${cidrhost(var.wireguard_network["ipv6"], 2 + count.index)}/128"}
EOF

}

data "template_file" "wg0conf" {
  template = file("${path.module}/files/wg0.conf")

  vars = {
    InterfaceAddress = "${cidrhost(var.wireguard_network["ipv4"], 1)}${var.ipv6 == 0 ? "" : ",${cidrhost(var.wireguard_network["ipv6"], 1)}"}"
    InterfaceListenPort = var.wireguard_network["port"]
    InterfacePrivateKey = local.wg_server_private_key
    Peers = join("\n", data.template_file.wireguard_peer.*.rendered)
  }
}

#
# WireGuard Algo helper
#

data "template_file" "wireguard_peer_pubkey_configure" {
  count = length(var.vpn_users)

  template = <<-EOF
    ${count.index == 0 ? "set -x" : ":"}
    PUBKEY=$(wg pubkey <<< '${base64encode(random_string.wg_client_private_key.*.result[count.index])}')
    sed s~::${var.vpn_users[count.index]}::~$PUBKEY~ -i /etc/wireguard/wg0.conf
    ${count.index + 1 == length(var.vpn_users) ? "systemctl restart wg-quick@wg0" : "true"}
    wg pubkey <<< '${base64encode(random_string.wg_server_private_key.result)}' > /etc/wireguard/.wg-server.pub
EOF

}

data "template_file" "wireguard" {
template = file("${path.module}/cloud-init/020-wireguard.yml")

vars = {
wg0Conf = jsonencode(data.template_file.wg0conf.rendered)
wg0Sh = jsonencode(
join(
"\n",
data.template_file.wireguard_peer_pubkey_configure.*.rendered,
),
)
}
}

output "wg_users_private" {
value = random_string.wg_client_private_key.*.result
}

output "wg_users_public" {
value = random_string.wg_client_private_key.*.result
}
