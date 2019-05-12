resource "tls_private_key" "client" {
  count       = length(var.vpn_users)
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "client" {
  count           = length(var.vpn_users)
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.client.*.private_key_pem[count.index]
  dns_names       = [var.vpn_users[count.index]]

  subject {
    common_name = var.vpn_users[count.index]
  }
}

resource "tls_locally_signed_cert" "client" {
  count = length(var.vpn_users)
  # depends_on            = [null_resource.user_crl]
  cert_request_pem      = tls_cert_request.client.*.cert_request_pem[count.index]
  ca_key_algorithm      = "ECDSA"
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 87600

  allowed_uses = [
    "client_auth",
    "server_auth",
    "key_encipherment",
    "digital_signature",
  ]
}

resource "local_file" "user_private_keys" {
  count    = length(var.vpn_users)
  content  = tls_private_key.client.*.private_key_pem[count.index]
  filename = "${var.algo_config}/ipsec/manual/${var.vpn_users[count.index]}.key.pem"
}

resource "local_file" "user_certs" {
  # depends_on = [null_resource.user_crl]
  count    = length(var.vpn_users)
  content  = tls_locally_signed_cert.client.*.cert_pem[count.index]
  filename = "${var.algo_config}/ipsec/manual/${var.vpn_users[count.index]}.crt.pem"

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-ec"]
    working_dir = "${var.algo_config}/ipsec/manual/"
    when        = create
    command     = <<-EOF
      mkdir .for_crl/ || true
      cp -f ${var.vpn_users[count.index]}.crt.pem \
        .for_crl/${var.vpn_users[count.index]}.crt.pem
    EOF
  }
}

resource "random_id" "client_p12_pass" {
  byte_length = 6
}

data "external" "pkcs12" {
  count = length(var.vpn_users)
  program = ["${path.cwd}/${path.module}/external/generate-p12.sh"]

  query = {
    user = var.vpn_users[count.index]
    cert = tls_locally_signed_cert.client.*.cert_pem[count.index]
    key = tls_private_key.client.*.private_key_pem[count.index]
    pass = random_id.client_p12_pass.hex
  }
}

data "external" "crl" {
  program = ["${path.cwd}/${path.module}/external/generate-crl.sh"]
  working_dir = "${var.algo_config}/ipsec/manual/"

  query = {
    users = join("\n", var.vpn_users)
    ca_cert = tls_self_signed_cert.ca.cert_pem
    ca_key = tls_private_key.ca.private_key_pem
  }
}
