#!/bin/bash
set -x

cat << 'EOF' > /root/inventory
[local]
localhost ansible_connection=local
EOF

sudo apt-get update
sudo apt-get install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt-get update
sudo apt-get install ansible -y
ansible-pull -U https://github.com/trailofbits/algo-ng -e 'server_name=${server_name} vpn_users=${vpn_users}' -i /root/inventory
