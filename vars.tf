variable "vpn_users" {
  description = "Add as many users as you want for your VPN server here. Credentials will be generated for each one"
  default = "dan,jack"
}

variable "algo_name" {
  default = "algo-ng"
}

# Chose your cloud provider
# Possible values are:
# - digitalocean
#

variable "provider" {
  description = "Chose your cloud provider. Possible values are: digitalocean"
}

variable "components" {
  type    = "map"
  default = {
    vpn             = true
    dns_adblocking  = true
    ssh_tunneling   = true
    security        = false
  }
}

variable "image" {
  type    = "map"
  default = {
    digitalocean  = "ubuntu-16-04-x64"
    ec2           = "ubuntu-xenial-16.04"
    gce           = "ubuntu-1604"
    azure         = "16.04-LTS"
  }
}

variable "size" {
  type    = "map"
  default = {
    digitalocean  = "512mb"
    ec2           = "t2.micro"
    gce           = "f1-micro"
    azure         = "Basic_A0"
  }
}

variable "region" {
  type    = "map"
  default = {
    digitalocean  = "ams3"
    ec2           = "us-east-1"
    gce           = "europe-west1-b"
    azure         = "westus2"
  }
}
