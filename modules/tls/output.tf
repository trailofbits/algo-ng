# output "ca_cert" {
#   value = "${var.algo_config}/pki/cacert.pem"
# }
#
# output "server_cert" {
#   value = "${var.algo_config}/pki/certs/${var.server_address}.crt"
# }
#
# output "server_key" {
#   value = "${var.algo_config}/pki/private/${var.server_address}.key"
# }
#
# output "crl" {
#   value = "${var.algo_config}/pki/crl/algo.root.pem"
# }

output "ca_cert" {
  value = "${tls_locally_signed_cert.ca.cert_pem}"
}

output "server_cert" {
  value = "${tls_locally_signed_cert.server.cert_pem}"
}

output "server_key" {
  value = "${tls_private_key.server.public_key_pem}"
}

# output "crl" {
#   value = ""
# }
