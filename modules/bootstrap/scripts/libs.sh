#!/usr/bin/env bash

set -euo pipefail

max_retry=60
counter=1
sleep_duration=3

export DEBIAN_FRONTEND="noninteractive"

count() {
  sleep $sleep_duration
  if [[ $counter -eq $max_retry ]]; then
    echo "Failed after $counter attempts!"
    exit 1
  fi
  echo "Trying again. Try #$counter"
  ((counter++))
}

try() {
  until "$@"; do
    count
  done
}
