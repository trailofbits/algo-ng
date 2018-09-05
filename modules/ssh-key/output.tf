output "public_key_openssh" {
  value = "${tls_private_key.algo_ssh.public_key_openssh}"
}

output "private_key_pem" {
  value = "${tls_private_key.algo_ssh.private_key_pem}"
}
