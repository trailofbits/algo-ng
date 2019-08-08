#!/usr/bin/env bash

set -uxo pipefail

umask 077

eval "$(jq -r '@sh "USERS=\(.users) CA_CERT=\(.ca_cert) CA_KEY=\(.ca_key)"')"

OPENSSLCNF="[ ca ]
default_ca=CA_default
[ CA_default ]
database=index.txt
crlnumber=crlnumber
default_days=3650
default_crl_days=3650
default_md=default
preserve=no
crl_extensions=crl_ext
[ crl_ext ]
authorityKeyIdentifier=keyid:always,issuer:always"


[ -f index.txt ]  || touch index.txt
[ -f crlnumber ]  || echo 00 > crlnumber
[ -f crl.pem ]    || openssl ca -gencrl -keyfile <(echo "$CA_KEY") -cert <(echo "$CA_CERT") -out crl.pem -config <(echo "$OPENSSLCNF")

cp -f users.txt users.txt.old || true
echo "$USERS" > users.txt

cat users.txt.old | while read userOld; do
  if grep -Ew "^${userOld}$" users.txt >/dev/null; then
    :
  else
    openssl ca -gencrl \
      -config <(echo "$OPENSSLCNF") \
      -keyfile <(echo "$CA_KEY") \
      -cert <(echo "$CA_CERT") \
      -revoke .for_crl/$userOld.crt.pem \
      -out .for_crl/$userOld.crt.pem_revoked
    openssl ca -gencrl \
      -config <(echo "$OPENSSLCNF") \
      -keyfile <(echo "$CA_KEY") \
      -cert <(echo "$CA_CERT") \
      -out crl.pem
  fi
done

jq -n --arg crl "$(cat crl.pem)\n$CA_CERT" '{"crl":$crl}'
