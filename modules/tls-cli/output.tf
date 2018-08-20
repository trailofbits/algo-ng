output "ca_cert" {
  value = "${var.algo_config}/pki/cacert.pem"
}

output "server_cert" {
  value = "${var.algo_config}/pki/certs/${var.server_address}.crt"
}

output "server_key" {
  value = "${var.algo_config}/pki/private/${var.server_address}.key"
}

output "crl" {
  value = "${var.algo_config}/pki/crl/algo.root.pem"
}
