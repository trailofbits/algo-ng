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
