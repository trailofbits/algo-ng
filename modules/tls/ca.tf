resource "tls_private_key" "ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm         = "ECDSA"
  private_key_pem       = "${tls_private_key.ca.private_key_pem}"
  validity_period_hours = 87600
  is_ca_certificate     = true
  subject {
    common_name  = "${var.server_address}"
  }
  allowed_uses = [
    "cert_signing",
    "crl_signing"
  ]
}
