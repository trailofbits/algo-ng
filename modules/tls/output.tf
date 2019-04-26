output "ca_cert" {
  value = "${tls_self_signed_cert.ca.cert_pem}"
}

output "server_cert" {
  value = "${tls_locally_signed_cert.server.cert_pem}"
}

output "server_key" {
  value = "${tls_private_key.server.private_key_pem}"
}

output "clients_public_key_openssh" {
  value = ["${tls_private_key.client.*.public_key_openssh}"]
}

output "clients_p12_base64" {
  value = ["${local_file.client_p12_base64.*.content}"]
}

output "client_p12_pass" {
  value = "${random_id.client_p12_pass.hex}"
}

output "crl" {
  value = "${data.local_file.user_crl.content}"
}
