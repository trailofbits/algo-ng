locals {
  tags = {
    Name      = "algo-vpn-${var.deploy_id}"
    App       = "AlgoVPN"
    Workspace = terraform.workspace
    DeployID  = var.deploy_id
  }

  cloud_config = var.algo_config.clouds.ec2

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

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_shuffle" "az" {
  input        = data.aws_availability_zones.available.names
  result_count = 1
}

data "aws_ami_ids" "main" {
  owners = ["099720109477"]

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd-gp3/${local.cloud_config.image}-amd64-server-*",
    ]
  }
}

resource "aws_vpc" "main" {
  cidr_block                       = "172.16.0.0/16"
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = local.cloud_config.ipv6
  tags                             = local.tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = local.tags
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.254.0/23"
  ipv6_cidr_block   = local.cloud_config.ipv6 ? cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 1) : null
  availability_zone = random_shuffle.az.result.0
  tags              = local.tags
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = local.tags
}

resource "aws_route_table_association" "default" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.default.id
}

resource "aws_security_group" "main" {
  name   = "algo-vpn-${var.deploy_id}"
  vpc_id = aws_vpc.main.id
  tags   = local.tags

  dynamic "ingress" {
    for_each = concat([
      {
        "port" : 22
        "protocol" = "tcp"
      },
      {
        "port" : -1
        "protocol" = "icmp"
      }
    ], local.vpn_ports)

    content {
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      from_port        = ingress.value.port
      to_port          = ingress.value.port
      protocol         = ingress.value.protocol
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_key_pair" "main" {
  key_name   = "algo-vpn-${var.deploy_id}"
  public_key = var.ssh_key.public
}

resource "aws_instance" "main" {
  ami                                  = data.aws_ami_ids.main.ids.0
  instance_type                        = local.cloud_config.size
  instance_initiated_shutdown_behavior = "terminate"
  key_name                             = aws_key_pair.main.key_name
  vpc_security_group_ids               = [aws_security_group.main.id]
  subnet_id                            = aws_subnet.main.id
  user_data                            = var.user_data.cloudinit
  ipv6_address_count                   = local.cloud_config.ipv6 ? 1 : 0
  availability_zone                    = random_shuffle.az.result.0
  tags                                 = local.tags

  root_block_device {
    volume_size           = 8
    delete_on_termination = true
    encrypted             = local.cloud_config.encrypted
    kms_key_id            = local.cloud_config.kms_key_id
    tags                  = local.tags
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "main" {
  instance   = aws_instance.main.id
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  connection {
    type        = "ssh"
    host        = self.public_ip
    port        = 22
    user        = "ubuntu"
    private_key = var.ssh_key.private
    timeout     = "10m"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait  >/dev/null",
      "while ! systemctl --quiet is-system-running; do sleep 3; done",
    ]
  }
}
