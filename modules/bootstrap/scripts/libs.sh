#! /usr/bin/env bash

set -euo pipefail

max_retry=60
counter=0
sleep=3

export DEBIAN_FRONTEND="noninteractive"

count () {
  sleep $sleep
  [[ counter -eq $max_retry ]] && echo "Failed!" && exit 1
  echo "Trying again. Try #$counter"
  ((counter++))
}

try () {
  until $@; do
    count
  done
}
