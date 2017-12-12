#!/bin/bash -x

VPN_USERS="$1"
CA_PASSWORD="$2"

if [[ -e /opt/.algo_init ]]
then
  ARGS="-t update-users --skip-tags common"
else
  ARGS=""
  apt-get install software-properties-common -y
  apt-add-repository ppa:ansible/ansible -y
  rm -rf /var/lib/apt/lists/*
  apt-get clean
  sleep 10
  apt-get update
  apt-get install ansible -y
fi

cat << 'EOF' > /root/inventory
[local]
localhost ansible_connection=local
EOF

cat << 'EOF' > /etc/ansible/ansible.cfg
[defaults]
remote_tmp=$HOME/.ansible/tmp
local_tmp=$HOME/.ansible/tmp
pipelining = True
retry_files_enabled = False
host_key_checking = False
timeout = 60
EOF

PUBLIC_IP=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/ipv4/address)
sudo ansible-pull -U https://github.com/trailofbits/algo-ng playbooks/algo.yml -i /root/inventory $ARGS -e vpn_users=$VPN_USERS -e server_name=$PUBLIC_IP -e ca_password=$CA_PASSWORD | sudo tee -a /var/log/algo.log

sudo touch /opt/.algo_init
