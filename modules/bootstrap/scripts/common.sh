#! /usr/bin/env bash

. /opt/algo/scripts/libs.sh

try "apt-get update -yq" >/dev/null
try "apt-get install apparmor-utils unattended-upgrades passwd iptables-persistent -yq" >/dev/null

ln -sf /opt/algo/configs/common/50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades
ln -sf /opt/algo/configs/common/10periodic /etc/apt/apt.conf.d/10periodic
ln -sf /opt/algo/configs/common/99-algo-sysctl.conf /etc/sysctl.d/99-algo-sysctl.conf

mkdir /etc/iptables/ || true
ln -sf /opt/algo/configs/common/iptables-rules.v4 /etc/iptables/rules.v4
ln -sf /opt/algo/configs/common/iptables-rules.v6 /etc/iptables/rules.v6

systemctl restart iptables.service

sysctl -p -f /etc/sysctl.d/99-algo-sysctl.conf
