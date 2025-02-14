#! /usr/bin/env bash

. /opt/algo/scripts/libs.sh

try "apt-get install wireguard -yq -yq" >/dev/null

ln -sf /opt/algo/configs/wireguard/wg0.conf /etc/wireguard/wg0.conf

chmod 0600 /opt/algo/configs/wireguard/wg0.conf

systemctl enable wg-quick@wg0
systemctl restart wg-quick@wg0
