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
