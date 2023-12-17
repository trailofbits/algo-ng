locals {
  tags = {
    App = "AlgoVPN"
  }
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
      "ubuntu/images/hvm-ssd/${var.config.cloud.image}-amd64-server-*",
    ]
  }
}

resource "aws_vpc" "main" {
  cidr_block                       = "172.16.0.0/16"
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = var.config.cloud.ipv6
  tags                             = local.tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = local.tags
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.254.0/23"
  ipv6_cidr_block   = var.config.cloud.ipv6 ? cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 1) : null
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
  description = "Enable SSH and IPsec"
  vpc_id      = aws_vpc.main.id
  tags        = local.tags

  dynamic "ingress" {
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
        "port" : -1
        "protocol" = "icmp"
      }
    ]

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
  key_name_prefix = "algo-"
  public_key      = var.config.ssh_public_key
}

resource "aws_instance" "main" {
  ami                                  = data.aws_ami_ids.main.ids[0]
  instance_type                        = var.config.cloud.size
  instance_initiated_shutdown_behavior = "terminate"
  key_name                             = aws_key_pair.main.key_name
  vpc_security_group_ids               = [aws_security_group.main.id]
  subnet_id                            = aws_subnet.main.id
  user_data                            = var.config.user_data.cloudinit
  ipv6_address_count                   = var.config.cloud.ipv6 ? 1 : 0
  availability_zone                    = random_shuffle.az.result.0
  tags                                 = merge({ Name = var.config.algo_name }, local.tags)

  root_block_device {
    volume_size           = 8
    delete_on_termination = true
    encrypted             = var.config.cloud.encrypted
    kms_key_id            = var.config.cloud.kms_key_id
    tags                  = merge({ Name = var.config.algo_name }, local.tags)
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "main" {
  instance   = aws_instance.main.id
  vpc        = true
  depends_on = [aws_internet_gateway.main]
}
