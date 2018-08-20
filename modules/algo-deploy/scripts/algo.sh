#!/bin/bash -xe

VPN_USERS="$1"
PUBLIC_IP="$2"
ARGS="-t _null,$TAGS"

echo 'precedence ::ffff:0:0/96  100' >> /etc/gai.conf

apt-get install software-properties-common -y
apt-add-repository ppa:ansible/ansible -y
rm -rf /var/lib/apt/lists/*
apt-get clean
sleep 10
apt-get update
apt-get install ansible=2.5\* -y

cd /opt/algo/playbooks
ansible-playbook algo.yml $TAGS -e vpn_users=$VPN_USERS -e server_name=$PUBLIC_IP
