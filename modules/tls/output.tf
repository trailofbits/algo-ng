locals {
  pki = {
    ipsec = {
      server_cert = tls_locally_signed_cert.server.cert_pem
      server_key  = tls_private_key.server.private_key_pem
      ca_cert     = tls_self_signed_cert.ca.cert_pem
      pkcs12      = data.external.pkcs12.*.result.pkcs12
      crl         = data.external.crl.result.crl
    }

    wireguard = {
      client_private_keys = random_string.wg_client_private_key.*.result
      server_private_key  = random_string.wg_server_private_key.result
    }

    ssh = {
      public_keys  = tls_private_key.client.*.public_key_openssh
      private_keys = tls_private_key.client.*.private_key_pem
    }
  }
}

output "pki" {
  value = local.pki
}

output "client_p12_pass" {
  value = random_id.client_p12_pass.hex
}
