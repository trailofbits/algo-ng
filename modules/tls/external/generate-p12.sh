#!/usr/bin/env bash

set -euo pipefail

umask 077;

eval "$(jq -r '@sh "USER=\(.user) CERT=\(.cert) KEY=\(.key) PASS=\(.pass)"')"

base64encode () {
  if PY=$(which python2) >/dev/null; then
    $PY -c "import base64,sys; base64.encode(sys.stdin,sys.stdout)"
  elif PY=$(which python3) >/dev/null; then
    $PY -c "import base64,sys; print(base64.b64encode(sys.stdin.buffer.read()).decode('ascii'))"
  else
    echo "Python not found"
    exit 1
  fi
}

PKCS12=$(openssl pkcs12 \
  -in <(echo "${CERT}") \
  -inkey <(echo "${KEY}") \
  -export \
  -name ${USER} \
  -passout pass:"${PASS}" | base64encode)

jq -n --arg pkcs12 "$PKCS12" '{"pkcs12":$pkcs12}'
