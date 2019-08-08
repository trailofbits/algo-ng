#!/usr/bin/env bash

set -ex

SSH="$(which ssh)"
SSH_ARGS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
ADDRESS="$1"
KEY="$2"
FILE="$3"
WAIT="${4:-false}"

connect() {
  $SSH -i "${KEY}" ${SSH_ARGS} ${ADDRESS} $1
}

wait() {
  connect "until test -f ${FILE}; do sleep 5; done"
}

read() {
  FILE=$(connect "cat ${FILE} || echo null")
}

if [[ "${WAIT}" == "wait" ]]; then
  wait
fi

read

printf '{"result": "%s"}\n' "$FILE"
