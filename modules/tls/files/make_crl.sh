#!/usr/bin/env bash

set -e

umask 077

[ -f index.txt ]  || touch index.txt
[ -f crlnumber ]  || echo 00 > crlnumber
[ -f crl.pem ]    || openssl ca -gencrl -keyfile <(echo "$KEY") -cert <(echo "$CERT") -out crl.pem -config <(echo "$OPENSSLCNF")

cp -f users.txt users.txt.old || true

cat users.txt.old | while read user; do
  if [[ "$USERS" != *"$user"* ]]; then
    echo "$user to revoke" >> /tmp/crl
    openssl ca -gencrl \
      -config <(echo "$OPENSSLCNF") \
      -keyfile <(echo "$KEY") \
      -cert <(echo "$CERT") \
      -revoke .for_crl/$user.crt.pem \
      -out .for_crl/$user.crt.pem_revoked
    openssl ca -gencrl \
      -config <(echo "$OPENSSLCNF") \
      -keyfile <(echo "$KEY") \
      -cert <(echo "$CERT") \
      -out crl.pem
  fi
done

echo "$USERS" | tr ',' '\n' > users.txt
echo -en "$(cat crl.pem)\n$CERT" > crl.full.pem
