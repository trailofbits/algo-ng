resource "null_resource" "TLS_server_req" {
  depends_on = ["null_resource.TLS_ca"]
  provisioner "local-exec" {
    environment {
      IP_subject_alt_name = "${var.server_address}"
    }
    interpreter = [ "/bin/bash", "-c" ]
    working_dir = "${var.algo_config}/pki/"
    command =<<EOT
      openssl ec -noout -in private/$IP_subject_alt_name.key ||
      openssl req -utf8 -new \
        -newkey ec:ecparams/prime256v1.pem \
        -config ${var.openssl_config} \
        -keyout private/$IP_subject_alt_name.key \
        -out reqs/$IP_subject_alt_name.req -nodes \
        -passin pass:"$TLS_CA_KEY_PASSWORD" \
        -subj "/CN=$IP_subject_alt_name" -batch &&
      cp -f private/$IP_subject_alt_name.key server_ssl/
EOT
  }
}

resource "null_resource" "TLS_server_ca" {
  depends_on = ["null_resource.TLS_server_req"]
  provisioner "local-exec" {
    environment {
      IP_subject_alt_name = "${var.server_address}"
    }
    interpreter = [ "/bin/bash", "-c" ]
    working_dir = "${var.algo_config}/pki/"
    command =<<EOT
      openssl x509 -noout -in certs/$IP_subject_alt_name.crt ||
      openssl ca -utf8 \
        -in reqs/$IP_subject_alt_name.req \
        -out certs/$IP_subject_alt_name.crt \
        -config ${var.openssl_config} \
        -days 3650 -batch \
        -passin pass:"$TLS_CA_KEY_PASSWORD" \
        -subj "/CN=$IP_subject_alt_name" &&
      cp -f certs/$IP_subject_alt_name.crt server_ssl/
EOT
  }
}
