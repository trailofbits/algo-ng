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

data "template_file" "mobileconfig" {
  count    = "${length(var.vpn_users)}"
  template = "${file("${path.module}/files/mobileconfig.xml")}"
  vars {
    OnDemandEnabled           = 0
    LocalIdentifier           = "${var.vpn_users[count.index]}"
    server_address            = "${var.server_address}"
    PayloadContent            = "${base64encode(var.clients_p12[count.index])}"
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
  content     = "${data.template_file.mobileconfig.*.rendered[count.index]}"
  filename    = "${var.algo_config}/${var.vpn_users[count.index]}.mobileconfig"

  provisioner "local-exec" {
    command = "chmod 0600 ${var.algo_config}/${var.vpn_users[count.index]}.mobileconfig"
  }
}
