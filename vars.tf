variable "vpn_users" {
  default = [
    "dan",
    "jack",
  ]
}

variable "also_ssh_private" {
  default = "configs/algo_ssh.pem"
}

variable "cloud_digitalocean" {
  default = "true"
}

variable "algo_instance" {
  default = ""
}

variable "git_source" {
  default = "https://github.com/trailofbits/algo-ng"
}

variable "deploy_playbook" {
  default = "playbooks/algo.yml"
}
