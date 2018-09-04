resource "digitalocean_ssh_key" "algo" {
  name       = "${var.algo_name}"
  public_key = "${var.public_key_openssh}"
}

resource "digitalocean_tag" "algo" {
  name = "Environment:Algo"
}

resource "digitalocean_droplet" "algo" {
  name      = "${var.algo_name}"
  image     = "${var.image}"
  size      = "${var.size}"
  region    = "${var.region}"
  user_data = "${var.user_data}"
  tags      = [ "${digitalocean_tag.algo.id}" ]
  ssh_keys  = [ "${digitalocean_ssh_key.algo.id}" ]
  ipv6      = true
}

resource "digitalocean_floating_ip" "algo" {
  droplet_id = "${digitalocean_droplet.algo.id}"
  region     = "${digitalocean_droplet.algo.region}"
}

resource "null_resource" "deploy_certificates" {
  triggers = {
    digitalocean_droplet      = "${digitalocean_droplet.algo.id}"
  }

  connection {
    host        = "${digitalocean_droplet.algo.ipv4_address}"
    user        = "root"
    private_key = "${var.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = ["bash -c 'mkdir -p /etc/ipsec.d/{cacerts,certs,private}'"]
  }

  provisioner "file" {
    content     = "${var.ca_cert}"
    destination = "/etc/ipsec.d/cacerts/ca.pem"
  }

  provisioner "file" {
    content     = "${var.server_cert}"
    destination = "/etc/ipsec.d/certs/server.pem"
  }

  provisioner "file" {
    content     = "${var.server_key}"
    destination = "/etc/ipsec.d/private/server.pem"
  }

  provisioner "remote-exec" {
    inline = ["systemctl status strongswan >/dev/null 2>&1 && systemctl restart strongswan || true"]
  }
}
