locals {
  tags = {
    App       = "AlgoVPN"
    Workspace = terraform.workspace
    DeployID  = var.config.deploy_id
  }
}

resource "aws_lightsail_key_pair" "main" {
  name       = "algo-key-${var.config.deploy_id}"
  public_key = var.config.ssh_public_key
}

resource "aws_lightsail_instance" "main" {
  name              = "algo-srv-${var.config.deploy_id}"
  availability_zone = var.config.cloud.availability_zone
  blueprint_id      = var.config.cloud.image
  bundle_id         = var.config.cloud.size
  user_data         = var.config.user_data.script
  key_pair_name     = aws_lightsail_key_pair.main.name
  tags              = local.tags
}

resource "aws_lightsail_static_ip" "main" {
  name = "algo-ip-${var.config.deploy_id}"
}

resource "aws_lightsail_static_ip_attachment" "main" {
  static_ip_name = aws_lightsail_static_ip.main.id
  instance_name  = aws_lightsail_instance.main.id
}

resource "aws_lightsail_instance_public_ports" "main" {
  instance_name = aws_lightsail_instance.main.name

  dynamic "port_info" {
    for_each = [
      {
        "port" : 22
        "protocol" = "tcp"
      },
      {
        "port" : var.config.tfvars.wireguard.port,
        "protocol" = "udp"
      },
      {
        "port" : 0
        "protocol" = "icmp"
      }
    ]

    content {
      cidrs     = ["0.0.0.0/0"]
      from_port = port_info.value.port
      to_port   = port_info.value.port
      protocol  = port_info.value.protocol
    }
  }

  depends_on = [
    aws_lightsail_instance.main,
    aws_lightsail_static_ip.main,
    aws_lightsail_static_ip_attachment.main
  ]
}
