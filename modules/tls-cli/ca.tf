resource "null_resource" "TLS_ca" {
  depends_on = ["null_resource.TLS_main"]
  provisioner "local-exec" {
    environment {
      IP_subject_alt_name = "${var.server_address}"
    }
    interpreter = [ "/bin/bash", "-c" ]
    working_dir = "${var.algo_config}/pki/"
    command =<<EOT
      openssl ecparam -name prime256v1 -out ecparams/prime256v1.pem &&
      openssl req -utf8 -new \
        -newkey ec:ecparams/prime256v1.pem \
        -config ${var.openssl_config} \
        -keyout private/cakey.pem \
        -out cacert.pem -x509 -days 3650 \
        -batch \
        -passout pass:"$TLS_CA_KEY_PASSWORD" &&
      cp -f cacert.pem ../cacert.pem &&
      mkdir server_ssl &&
      echo 01 > serial
EOT
  }
}
