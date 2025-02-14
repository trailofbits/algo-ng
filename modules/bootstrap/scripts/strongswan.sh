#! /usr/bin/env bash

. /opt/algo/scripts/libs.sh

try "apt-get install strongswan -yq -yq" >/dev/null

cat /opt/algo/configs/strongswan/ipsec.conf > /etc/ipsec.conf
cat /opt/algo/configs/strongswan/ca-cert.pem > /etc/ipsec.d/cacerts/ca.crt
cat /opt/algo/configs/strongswan/server-cert.pem > /etc/ipsec.d/certs/server.pem
cat /opt/algo/configs/strongswan/server-key.pem > /etc/ipsec.d/private/server.pem

echo ": ECDSA server.pem" > /etc/ipsec.secrets

chmod 0600 /opt/algo/configs/strongswan/server-key.pem

systemctl enable strongswan-starter.service
systemctl restart strongswan-starter.service
