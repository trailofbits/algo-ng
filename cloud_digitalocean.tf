variable "do_token" {
  description = "Enter your API token. The token must have read and write permissions (https://cloud.digitalocean.com/settings/api/tokens):"
}

variable "do_image" {
  default = "ubuntu-16-04-x64"
}

variable "do_size" {
  default = "512mb"
}

variable "do_region" {
  default = "ams3"
}

provider "digitalocean" {
  token = "${var.do_token}"
}

resource "digitalocean_ssh_key" "algo" {
  count      = "${var.cloud_digitalocean == "true" ? 1 : 0}"
  name       = "algo-ng"
  public_key = "${tls_private_key.algo_ssh.public_key_openssh}"
}

resource "digitalocean_droplet" "algo" {
  count     = "${var.cloud_digitalocean == "true" ? 1 : 0}"
  image     = "ubuntu-16-04-x64"
  name      = "algo-ng"
  region    = "ams3"
  size      = "512mb"
  ipv6      = true
  user_data = "${data.template_cloudinit_config.cloud_init.rendered}"
  private_networking = true
  ssh_keys  = [
    "${digitalocean_ssh_key.algo.id}"
  ]

  provisioner "remote-exec" {
    inline  = [ "# Connected!" ]

    connection {
      type        = "ssh"
      host        = "${digitalocean_droplet.algo.ipv4_address}"
      private_key = "${tls_private_key.algo_ssh.private_key_pem}"
    }
  }

  provisioner "remote-exec" {
    inline  = [
      "mkdir -p /opt/algo/",
      "echo ${join(",", var.vpn_users)} > /opt/algo/.vpn_users"
    ]
    connection {
      type        = "ssh"
      host        = "${digitalocean_droplet.algo.ipv4_address}"
      private_key = "${tls_private_key.algo_ssh.private_key_pem}"
    }
  }
}

resource "digitalocean_floating_ip" "algo" {
  count       = "${var.cloud_digitalocean == "true" ? 1 : 0}"
  droplet_id  = "${digitalocean_droplet.algo.id}"
  region      = "${digitalocean_droplet.algo.region}"
}

output "INSTANCE" {
  value = "${digitalocean_floating_ip.algo.ip_address}"
}

resource "null_resource" "update_server_ip" {
  count   = "${var.cloud_digitalocean == "true" ? 1 : 0}"
  triggers {
    instance = "${digitalocean_droplet.algo.id}"
  }

  connection {
    type        = "ssh"
    host        = "${digitalocean_floating_ip.algo.ip_address}"
    private_key = "${tls_private_key.algo_ssh.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = ["# Connected!"]
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /opt/algo/",
      "echo ${digitalocean_floating_ip.algo.ip_address} > /opt/algo/.server_ip"
    ]
  }
}

resource "null_resource" "update_users" {
  count   = "${var.cloud_digitalocean == "true" ? 1 : 0}"
  triggers {
    vpn_users = "${join(",", var.vpn_users)}"
  }

  connection {
    type        = "ssh"
    host        = "${digitalocean_floating_ip.algo.ip_address}"
    private_key = "${tls_private_key.algo_ssh.private_key_pem}"
  }

  provisioner "remote-exec" {
    inline = [ "# Connected!" ]
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /opt/algo/",
      "echo ${join(",", var.vpn_users)} > /opt/algo/.vpn_users",
      "${var.ansible_command} -t update_users | tee -a /var/log/algo.log"
    ]
  }
}
