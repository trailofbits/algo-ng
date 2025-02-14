locals {
  tags = {
    App       = "AlgoVPN"
    Workspace = terraform.workspace
    DeployID  = var.deploy_id
  }

  cloud_config = var.algo_config.clouds.lightsail

  wireguard_ports = [{
    "port" : var.algo_config.wireguard.port,
    "protocol" = "udp"
  }]

  ipsec_ports = [{
    "port" : 500,
    "protocol" = "udp"
    },
    {
      "port" : 4500,
      "protocol" = "udp"
  }]

  vpn_ports = concat(
    var.algo_config.wireguard.enabled ? local.wireguard_ports : [],
    var.algo_config.ipsec.enabled ? local.ipsec_ports : [],
  )
}

resource "aws_lightsail_key_pair" "main" {
  name       = "algo-vpn-${var.deploy_id}"
  public_key = var.ssh_key.public
}

resource "aws_lightsail_instance" "main" {
  name              = "algo-vpn-${var.deploy_id}"
  availability_zone = local.cloud_config.availability_zone
  blueprint_id      = local.cloud_config.image
  bundle_id         = local.cloud_config.size
  user_data         = var.user_data.script
  key_pair_name     = aws_lightsail_key_pair.main.name
  tags              = local.tags
}

resource "aws_lightsail_static_ip" "main" {
  name = "algo-vpn-${var.deploy_id}"
}

resource "aws_lightsail_static_ip_attachment" "main" {
  static_ip_name = aws_lightsail_static_ip.main.id
  instance_name  = aws_lightsail_instance.main.id
}

resource "aws_lightsail_instance_public_ports" "main" {
  instance_name = aws_lightsail_instance.main.name

  dynamic "port_info" {
    for_each = concat([
      {
        "port" : 22
        "protocol" = "tcp"
      },
      {
        "port" : 0
        "protocol" = "icmp"
      }
    ], local.vpn_ports)

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
