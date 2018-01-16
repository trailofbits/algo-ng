resource "digitalocean_ssh_key" "algo" {
  name       = "${var.algo_name}"
  public_key = "${var.public_key_openssh}"
}

resource "digitalocean_droplet" "algo" {
  name      = "${var.algo_name}"
  image     = "${var.image}"
  size      = "${var.size}"
  region    = "${var.region}"
  user_data = "${var.user_data}"
  tags      = [ "Environment:Algo" ]
  ssh_keys  = [ "${digitalocean_ssh_key.algo.id}" ]
  ipv6      = true
}
