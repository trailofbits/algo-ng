vpn_users = "dan,jack2"
algo_ssh_private = "algo_ssh.pem"
ca_password = ""
algo_name = "algo-local"
components = {
    "vpn"             = true,
    "dns_adblocking"  = true,
    "ssh_tunneling"   = true,
    "security"        = false
}
image = {
    "digitalocean"    = "ubuntu-16-04-x64",
    "ec2"             = "ubuntu-xenial-16.04"
    "gce"             = "ubuntu-os-cloud/ubuntu-1604-lts"
}
size = {
    "digitalocean"    = "512mb",
    "ec2"             = "t2.micro"
    "gce"             = "f1-micro"
}
