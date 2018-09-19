output "ca_cert" {
  value = "${tls_self_signed_cert.ca.cert_pem}"
}

output "server_cert" {
  value = "${tls_locally_signed_cert.server.cert_pem}"
}

output "server_key" {
  value = "${tls_private_key.server.public_key_pem}"
}

output "clients_public_key_openssh" {
  value = ["${tls_private_key.client.*.public_key_openssh}"]
}

output "crl" {
  value = "${var.algo_config}/keys/crl.pem"
}
