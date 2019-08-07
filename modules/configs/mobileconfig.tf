resource "random_uuid" "PayloadIdentifier" {
  count = 4
}

locals {
  mobileconfig = {
    ondemand                 = var.config.ondemand
    vpn_users                = var.config.vpn_users
    server_address           = var.server_address
    algo_config              = var.algo_config
    PayloadContentCA         = base64encode(var.pki.ipsec.ca_cert)
    Password_pkcs12          = var.client_p12_pass
    PayloadIdentifier_vpn    = upper(random_uuid.PayloadIdentifier.0.result)
    PayloadIdentifier_pkcs12 = upper(random_uuid.PayloadIdentifier.1.result)
    PayloadIdentifier_ca     = upper(random_uuid.PayloadIdentifier.2.result)
    PayloadIdentifier_conf   = upper(random_uuid.PayloadIdentifier.3.result)
  }
}

resource "local_file" "mobileconfig" {
  count    = length(var.config.vpn_users)
  content  = templatefile("${path.module}/files/mobileconfig.xml", { var = local.mobileconfig, index = count.index, pki = var.pki })
  filename = "${var.algo_config}/ipsec/apple/${var.config.vpn_users[count.index]}.mobileconfig"
}
