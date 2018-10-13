resource "random_uuid" "PayloadCertificateUUID" {
  count = "${length(var.vpn_users)}"
}

resource "random_uuid" "PayloadIdentifier_vpn" {
  count = "${length(var.vpn_users)}"
}

resource "random_uuid" "PayloadIdentifier_pkcs12" {
  count = "${length(var.vpn_users)}"
}

resource "random_uuid" "PayloadIdentifier_ca" {
  count = "${length(var.vpn_users)}"
}

resource "random_uuid" "PayloadIdentifier_conf" {
  count = "${length(var.vpn_users)}"
}

#
# IPsec
#

locals {
  WiFi_Exclude =<<EOF
<dict>
  <key>Action</key>
  <string>Disconnect</string>
  <key>InterfaceTypeMatch</key>
  <string>WiFi</string>
  <key>SSIDMatch</key>
  <array>
    ${join("\n", formatlist("<string>%s</string>", split(",", var.ondemand["wifi_exclude"])))}
  </array>
</dict>
EOF
  WiFi_OnDemand =<<EOF
<dict>
  <key>Action</key>
    <string>Connect</string>
  <key>InterfaceTypeMatch</key>
    <string>${var.ondemand["wifi"] == 1 ? "WiFi" : ""}</string>
  <key>URLStringProbe</key>
    <string>http://captive.apple.com/hotspot-detect.html</string>
</dict>
EOF

  Cellular_OnDemand =<<EOF
<dict>
  <key>Action</key>
    <string>Connect</string>
  <key>InterfaceTypeMatch</key>
    <string>${var.ondemand["cellular"] == 1 ? "Cellular" : ""}</string>
  <key>URLStringProbe</key>
    <string>http://captive.apple.com/hotspot-detect.html</string>
</dict>
EOF
}

data "template_file" "mobileconfig" {
  count    = "${length(var.vpn_users)}"
  template = "${file("${path.module}/files/mobileconfig.xml")}"
  vars {
    OnDemandEnabled           = "${var.ondemand["cellular"] == 1 || var.ondemand["wifi"] == 1 ? 1 : 0}"
    WiFi_Exclude              = "${length(var.ondemand["wifi_exclude"]) >= 1 && var.ondemand["wifi"] == 1 ? "${local.WiFi_Exclude}" : ""}"
    Cellular_OnDemand         = "${var.ondemand["cellular"] == 1 ? "${local.Cellular_OnDemand}" : ""}"
    WiFi_OnDemand             = "${var.ondemand["wifi"] == 1 ? "${local.WiFi_OnDemand}" : ""}"
    LocalIdentifier           = "${var.vpn_users[count.index]}"
    server_address            = "${var.server_address}"
    PayloadContent            = "${var.clients_p12_base64[count.index]}"
    PayloadIdentifier_vpn     = "${upper(random_uuid.PayloadIdentifier_vpn.*.result[count.index])}"
    PayloadIdentifier_pkcs12  = "${upper(random_uuid.PayloadIdentifier_pkcs12.*.result[count.index])}"
    PayloadIdentifier_ca      = "${upper(random_uuid.PayloadIdentifier_ca.*.result[count.index])}"
    PayloadIdentifier_conf    = "${upper(random_uuid.PayloadIdentifier_conf.*.result[count.index])}"
    PayloadContentCA          = "${base64encode(var.ca_cert)}"
    Password_pkcs12           = "${var.client_p12_pass}"
  }
}

resource "local_file" "mobileconfig" {
  count    = "${length(var.vpn_users)}"
  content  = "${data.template_file.mobileconfig.*.rendered[count.index]}"
  filename = "${var.algo_config}/${var.vpn_users[count.index]}.mobileconfig"

  provisioner "local-exec" {
    command = "chmod 0600 ${var.algo_config}/${var.vpn_users[count.index]}.mobileconfig"
  }
}

#
# IPsec powershell
#

data "template_file" "powershell" {
  count    = "${length(var.vpn_users)}"
  template = "${file("${path.module}/files/powershell.ps1")}"
  vars {
    username            = "${var.vpn_users[count.index]}"
    server_address      = "${var.server_address}"
    UserPkcs12Base64    = "${var.clients_p12_base64[count.index]}"
    CaCertificateBase64 = "${base64encode(var.ca_cert)}"
  }
}

resource "local_file" "powershell" {
  count    = "${length(var.vpn_users)}"
  content     = "${data.template_file.powershell.*.rendered[count.index]}"
  filename    = "${var.algo_config}/${var.vpn_users[count.index]}.ps1"

  provisioner "local-exec" {
    command = "chmod 0600 ${var.algo_config}/${var.vpn_users[count.index]}.ps1"
  }
}

#
# WireGuard
#

data "local_file" "wg_server_pubkey" {
  depends_on  = ["null_resource.get_wireguard_server_pubkey"]
  filename    = "${var.algo_config}/.wg-server.pub"
}

resource "local_file" "wireguard" {
  count    = "${length(var.vpn_users)}"
  filename = "${var.algo_config}/${var.vpn_users[count.index]}.wg.conf"
  content  =<<EOF
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
