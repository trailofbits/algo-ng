resource "tls_private_key" "client" {
  count       = "${length(var.vpn_users)}"
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "client" {
  count           = "${length(var.vpn_users)}"
  key_algorithm   = "ECDSA"
  private_key_pem = "${tls_private_key.client.*.private_key_pem[count.index]}"
  subject {
    common_name  = "${var.vpn_users[count.index]}"
  }
}

resource "tls_locally_signed_cert" "client" {
  count                 = "${length(var.vpn_users)}"
  depends_on            = ["null_resource.user_crl"]
  cert_request_pem      = "${tls_cert_request.client.*.cert_request_pem[count.index]}"
  ca_key_algorithm      = "ECDSA"
  ca_private_key_pem    = "${tls_private_key.client.*.private_key_pem[count.index]}"
  ca_cert_pem           = "${tls_self_signed_cert.ca.cert_pem}"
  validity_period_hours = 87600
  allowed_uses          = [
    "client_auth",
    "server_auth",
    "1.3.6.1.5.5.7.3.17"
  ]
}

resource "local_file" "user_private_keys" {
  count     = "${length(var.vpn_users)}"
  content   = "${tls_private_key.client.*.private_key_pem[count.index]}"
  filename  = "${var.algo_config}/keys/${var.vpn_users[count.index]}.key.pem"

  provisioner "local-exec" {
    command = "chmod 0600 ${var.algo_config}/keys/${var.vpn_users[count.index]}.key.pem"
  }
}

resource "local_file" "user_certs" {
  depends_on = ["null_resource.user_crl"]
  count     = "${length(var.vpn_users)}"
  content   = "${tls_locally_signed_cert.client.*.cert_pem[count.index]}"
  filename  = "${var.algo_config}/keys/${var.vpn_users[count.index]}.crt.pem"

  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-ec" ]
    working_dir = "${var.algo_config}/keys/"
    command     =<<EOF
chmod 0600 ${var.vpn_users[count.index]}.crt.pem
mkdir .for_crl/ || true
cp -f ${var.vpn_users[count.index]}.crt.pem \
      .for_crl/${var.vpn_users[count.index]}.crt.pem
EOF
  }
}

resource "local_file" "user_ssh_private_keys" {
  count     = "${lookup(var.components, "ssh_tunneling") == 0 ? 0 : length(var.vpn_users)}"
  content   = "${tls_private_key.client.*.private_key_pem[count.index]}"
  filename  = "${var.algo_config}/${var.vpn_users[count.index]}.ssh.pem"

  provisioner "local-exec" {
    command = "chmod 0600 ${var.algo_config}/${var.vpn_users[count.index]}.ssh.pem"
  }
}

resource "null_resource" "user_crl" {
  triggers {
    vpn_users = "${join(",", var.vpn_users)}"
  }

  provisioner "local-exec" {
    interpreter = [ "/bin/bash", "-ec" ]
    working_dir = "${var.algo_config}/keys/"
    command =<<EOF

[ -f index.txt ]  || touch index.txt
[ -f crlnumber ]  || echo 00 > crlnumber
[ -f crl.pem ]    || openssl ca -gencrl -keyfile <(echo "$KEY") -cert <(echo "$CERT") -out crl.pem -config <(echo "$OPENSSLCNF")

cp -f users.txt users.txt.old || true

cat users.txt.old | while read user; do
  if [[ "$USERS" != *"$user"* ]]; then
    echo "$user to revoke" >> /tmp/crl
    openssl ca -revoke .for_crl/$user.crt.pem \
      -config <(echo "$OPENSSLCNF") \
      -keyfile <(echo "$KEY") \
      -cert <(echo "$CERT")
    openssl ca -gencrl \
      -config <(echo "$OPENSSLCNF") \
      -keyfile <(echo "$KEY") \
      -cert <(echo "$CERT") \
      -out crl.pem
  fi
done

echo "${join("\n", var.vpn_users)}" > users.txt
echo -en "$(cat crl.pem)\n$CERT" > crl.full.pem
EOF
    environment {
      USERS       = "${join(",", var.vpn_users)}"
      KEY         = "${tls_private_key.ca.private_key_pem}"
      CERT        = "${tls_self_signed_cert.ca.cert_pem}"
      OPENSSLCNF =<<EOF
[ ca ]
default_ca=CA_default
[ CA_default ]
database=index.txt
crlnumber=crlnumber
default_days=3650
default_crl_days=3650
default_md=default
preserve=no
[ crl_ext ]
authorityKeyIdentifier=keyid:always,issuer:always
EOF
    }
  }
}
