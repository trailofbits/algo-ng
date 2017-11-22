variable "also_ssh_private" {
  default = "configs/algo_ssh.pem"
}

variable "git_source" {
  default = "https://github.com/trailofbits/algo-ng"
}

variable "ansible_command" {
  default = "ansible-pull -U https://github.com/trailofbits/algo-ng playbooks/algo.yml -e 'server_name=$(cat /opt/algo/.server_ip) vpn_users=$(cat /opt/algo/.vpn_users)' -i /root/inventory"
}
