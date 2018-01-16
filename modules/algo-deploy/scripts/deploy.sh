#!/bin/bash -xe

VPN_USERS="$1"
CA_PASSWORD="$2"
# PUBLIC_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
PUBLIC_IP="$3"
TAGS="$4"
ansible_ssh_user="$5"
ansible_ssh_private_key_file="$6"

echo 'precedence ::ffff:0:0/96  100' >> /etc/gai.conf

if [[ -e /opt/.algo_init ]]
then
  ARGS="-t update-users --skip-tags common"
else
  ARGS="-t _null,$TAGS"
  apt-get install software-properties-common -y
  apt-add-repository ppa:ansible/ansible -y
  rm -rf /var/lib/apt/lists/*
  apt-get clean
  sleep 10
  apt-get update
  apt-get install ansible -y
fi

cd /opt/algo/playbooks
ansible-playbook algo.yml $ARGS -e vpn_users=$VPN_USERS -e server_name=$PUBLIC_IP -e ca_password=$CA_PASSWORD -e ansible_ssh_user=$ansible_ssh_user -e ansible_ssh_private_key_file=$ansible_ssh_private_key_file
touch /opt/.algo_init
