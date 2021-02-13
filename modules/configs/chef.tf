locals {
  chef_attributes = {
    algo = {
      wireguard = {
        config = {
          Interface = {
            PrivateKey = var.pki.wireguard.server_private_key
          }
        }
      }
    }
  }
}

resource "null_resource" "run_chef" {
  depends_on = [null_resource.wait-until-deploy-finished]
  triggers   = { server_id = var.server_id }

  connection {
    host        = var.server_address
    user        = var.ssh_user
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = [
      "CHEF_LICENSE="accept-silent" chef-client -z -j /tmp/chef-attributes.json",
    ]
  }

  provisioner "file" {
    content     = jsonencode(local.chef_attributes)
    destination = "/tmp/chef-attributes.json"
  }
}
