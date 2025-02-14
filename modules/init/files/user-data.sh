#!/bin/sh
set -eux

#####
# shellcheck disable=SC2015
dpkg -l sshguard && until apt-get remove -y --purge sshguard; do
  sleep 3
done || true
