resource "digitalocean_ssh_key" "main" {
  name       = "${var.algo_name}"
  public_key = "${var.public_key_openssh}"
}

resource "digitalocean_tag" "main" {
  name = "Environment:Algo"
}

resource "digitalocean_droplet" "main" {
  name      = "${var.algo_name}"
  image     = "${var.image}"
  size      = "${var.size}"
  region    = "${var.region}"
  user_data = "${var.user_data}"
  tags      = ["${digitalocean_tag.main.id}"]
  ssh_keys  = ["${digitalocean_ssh_key.main.id}"]
  ipv6      = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_floating_ip_assignment" "foobar" {
  ip_address = "${var.algo_ip}"
  droplet_id = "${digitalocean_droplet.main.id}"
}
