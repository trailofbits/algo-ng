#! /usr/bin/env bash

. /opt/algo/scripts/libs.sh

try "apt-get install dnscrypt-proxy -yq" >/dev/null

ln -sf /opt/algo/configs/dnscrypt-proxy/dnscrypt-proxy.socket /lib/systemd/system/dnscrypt-proxy.socket
systemctl daemon-reload

ln -sf /opt/algo/configs/dnscrypt-proxy/apparmor.profile.dnscrypt-proxy /etc/apparmor.d/usr.bin.dnscrypt-proxy
aa-enforce usr.bin.dnscrypt-proxy

ln -sf /opt/algo/configs/dnscrypt-proxy/dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
ln -sf /opt/algo/configs/dnscrypt-proxy/ip-blacklist.txt /etc/dnscrypt-proxy/ip-blacklist.txt
ln -sf /opt/algo/configs/dnscrypt-proxy/dnscrypt-adblock.list /etc/dnscrypt-proxy/adblock.list
bash /opt/algo/scripts/dnscrypt-adblock.sh

ln -sf /opt/algo/configs/dnscrypt-proxy/adblock-cron /etc/cron.d/adblock-cron

systemctl restart dnscrypt-proxy dnscrypt-proxy.socket
