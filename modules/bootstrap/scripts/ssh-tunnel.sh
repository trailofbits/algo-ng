#! /usr/bin/env bash

. /opt/algo/scripts/libs.sh

newusers /opt/algo/configs/ssh-tunnel/newusers

groupadd -f algo-ssh-tunnel -g 15000
gpasswd -M $(cat /opt/algo/configs/ssh-tunnel/users) algo-ssh-tunnel

ln -sf /opt/algo/configs/ssh-tunnel/sshd_config /etc/ssh/sshd_config.d/90-algo.conf

systemctl reload ssh
