resource "tls_private_key" "server" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "server" {
  key_algorithm   = "ECDSA"
  private_key_pem = "${tls_private_key.server.private_key_pem}"

  subject {
    common_name  = "${var.server_address}"
  }
  ip_addresses = [
    "${var.server_address}"
  ]
}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem      = "${tls_cert_request.server.cert_request_pem}"
  ca_key_algorithm      = "ECDSA"
  ca_private_key_pem    = "${tls_private_key.server.private_key_pem}"
  ca_cert_pem           = "${tls_self_signed_cert.ca.cert_pem}"
  validity_period_hours = 87600
  allowed_uses          = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth"
  ]
}
