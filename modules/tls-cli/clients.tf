resource "null_resource" "TLS_clients_req" {
  depends_on = ["null_resource.TLS_server_ca"]
  count      = "${length(var.vpn_users)}"
  triggers {
    vpn_users = "${join(",", var.vpn_users)}"
  }

  provisioner "local-exec" {
    environment {
      IP_subject_alt_name = "${var.server_address}"
      USER                = "${element(var.vpn_users, count.index)}"
    }
    interpreter = [ "/bin/bash", "-c" ]
    working_dir = "${var.algo_config}/pki/"
    command =<<EOT
      openssl ec -noout -in private/$USER.key ||
      openssl req -utf8 -new \
        -newkey ec:ecparams/prime256v1.pem \
        -config ${var.openssl_config} \
        -keyout private/$USER.key \
        -out reqs/$USER.req -nodes \
        -passin pass:"$TLS_CA_KEY_PASSWORD" \
        -subj "/CN=$USER" -batch &&
      chmod 0600 private/$USER.key
EOT
  }
}

resource "null_resource" "TLS_clients_ca" {
  depends_on = ["null_resource.TLS_clients_req"]
  count      = "${length(var.vpn_users)}"
  triggers {
    vpn_users = "${join(",", var.vpn_users)}"
  }

  provisioner "local-exec" {
    environment {
      IP_subject_alt_name = "${var.server_address}"
      USER                = "${element(var.vpn_users, count.index)}"
    }
    interpreter = [ "/bin/bash", "-c" ]
    working_dir = "${var.algo_config}/pki/"
    command =<<EOT
      openssl x509 -noout -in certs/$USER.crt ||
      openssl ca -utf8 \
        -in reqs/$USER.req \
        -out certs/$USER.crt \
        -config ${var.openssl_config} \
        -days 3650 -batch \
        -passin pass:"$TLS_CA_KEY_PASSWORD" \
        -subj "/CN=$USER"
EOT
  }
}

resource "null_resource" "TLS_clients_p12" {
  depends_on = ["null_resource.TLS_clients_ca"]
  count      = "${length(var.vpn_users)}"
  triggers {
    vpn_users = "${join(",", var.vpn_users)}"
  }

  provisioner "local-exec" {
    environment {
      IP_subject_alt_name = "${var.server_address}"
      USER                = "${element(var.vpn_users, count.index)}"
    }
    interpreter = [ "/bin/bash", "-c" ]
    working_dir = "${var.algo_config}/pki/"
    command =<<EOT
      openssl pkcs12 \
        -in certs/$USER.crt \
        -inkey private/$USER.key \
        -export \
        -name $USER \
        -out private/$USER.p12 \
        -passout pass:"$TLS_P12_PASSWORD" &&
      chmod 0600 private/$USER.p12
EOT
  }
}

resource "null_resource" "TLS_clients_revoke" {
  depends_on = ["null_resource.TLS_clients_p12"]
  triggers {
    vpn_users = "${join(",", var.vpn_users)}"
  }

  provisioner "local-exec" {
    environment {
      IP_subject_alt_name = "${var.server_address}"
      USERS               = "${join(",", var.vpn_users)}"
    }
    interpreter = [ "/bin/bash", "-c" ]
    working_dir = "${var.algo_config}/pki/"
    command =<<EOT
      grep ^V index.txt | grep -v "CN=$IP_subject_alt_name" | awk '{print $5}' | sed 's/\/CN=//g' |
        while read active_user; do
          echo "$USERS" | grep -w $active_user ||
            openssl ca -gencrl -config ${var.openssl_config} \
              -passin pass:"$TLS_CA_KEY_PASSWORD" \
              -revoke certs/$active_user.crt \
              -out crl/$active_user.crt;
        done &&

      openssl ca -gencrl -config ${var.openssl_config} \
        -passin pass:"$TLS_CA_KEY_PASSWORD" \
        -out crl/algo.root.pem \
EOT
  }
}
