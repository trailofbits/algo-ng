locals {
  tags = {
    App       = "AlgoVPN"
    Workspace = terraform.workspace
    DeployID  = var.config.deploy_id
  }
  algo_name = "algo-${var.config.deploy_id}-${random_integer.name.result}"
}


resource "random_integer" "name" {
  min = 1
  max = 99

  keepers = {
    user_data = md5(data.template_cloudinit_config.cloudinit.rendered)
  }
}

resource "hcloud_floating_ip" "main" {
  name          = "algo-${var.config.deploy_id}"
  type          = "ipv4"
  home_location = var.config.cloud.region
  labels        = local.tags
}

data "template_cloudinit_config" "cloudinit" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = var.config.user_data.script
  }

  part {
    content_type = "text/cloud-config"
    content      = <<-EOF
      #cloud-config
      write_files:
        - content: |
            network:
              version: 2
              renderer: networkd
              ethernets:
                eth0:
                  addresses:
                  - ${hcloud_floating_ip.main.ip_address}/32
          path: /etc/netplan/60-floating-ip.yaml
      runcmd:
        - sudo netplan apply
    EOF
  }

}

resource "hcloud_ssh_key" "main" {
  name       = "algo-${var.config.deploy_id}"
  public_key = var.config.ssh_public_key
}

resource "hcloud_server" "main" {
  name        = local.algo_name
  image       = var.config.cloud.image
  server_type = var.config.cloud.size
  location    = var.config.cloud.region
  user_data   = data.template_cloudinit_config.cloudinit.rendered
  ssh_keys    = [hcloud_ssh_key.main.id]
  backups     = false
  labels      = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "hcloud_floating_ip_assignment" "main" {
  floating_ip_id = hcloud_floating_ip.main.id
  server_id      = hcloud_server.main.id
}
