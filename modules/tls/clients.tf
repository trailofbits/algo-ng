resource "tls_private_key" "client" {
  count       = "${length(var.vpn_users)}"
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "client" {
  count           = "${length(var.vpn_users)}"
  key_algorithm   = "ECDSA"
  private_key_pem = "${element(tls_private_key.client.*.private_key_pem, count.index)}"
  subject {
    common_name  = "${element(var.vpn_users, count.index)}"
  }
}

resource "tls_locally_signed_cert" "client" {
  count                 = "${length(var.vpn_users)}"
  cert_request_pem      = "${element(tls_cert_request.client.*.cert_request_pem, count.index)}"
  ca_key_algorithm      = "ECDSA"
  ca_private_key_pem    = "${element(tls_private_key.client.*.private_key_pem, count.index)}"
  ca_cert_pem           = "${tls_self_signed_cert.ca.cert_pem}"
  validity_period_hours = 87600
  allowed_uses          = [
    "client_auth",
    "server_auth",
    "1.3.6.1.5.5.7.3.17"
  ]
}

resource "local_file" "foo" {
  count     = "${length(var.vpn_users)}"
  content   = "${element(tls_private_key.client.*.private_key_pem, count.index)}"
  filename  = "${var.algo_config}/${element(var.vpn_users, count.index)}.ssh.pem"

  provisioner "local-exec" {
    command = "chmod 0600 ${var.algo_config}/${element(var.vpn_users, count.index)}.ssh.pem"
  }
}

# resource "local_file" "algo_ssh_private" {
#   count       = "${length(var.vpn_users)}"
#   content     = "${join(",", var.vpn_users)}"
#   filename    = "/tmp/certs/${element(var.vpn_users, count.index)}.pem"
# }
#
# resource "null_resource" "TLS_clients_revoke" {
#   triggers {
#     vpn_users = "${join(",", var.vpn_users)}"
#   }
#
#   provisioner "local-exec" {
#     environment {
#       IP_subject_alt_name = "${var.server_address}"
#       USERS               = "${join(",", var.vpn_users)}"
#     }
#     interpreter = [ "/bin/bash", "-c" ]
#     command =<<EOT
#       ls -1 /tmp/certs/ | cut -f1 -d. | while read user; do
#         echo $USERS | grep -w $user || echo "$user should be revoked" >/tmp/revoked ;
#       done
# EOT
#   }
# }
