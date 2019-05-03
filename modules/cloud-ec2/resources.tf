data "aws_ami_ids" "main" {
  owners = ["099720109477"]

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd/${var.image}-amd64-server-*",
    ]
  }
}

resource "aws_ami_copy" "encrypted" {
  count             = "${var.encrypted == 1 ? 1 : 0}"
  name              = "AlgoVPN encrypted AMI"
  description       = "An encrypted copy of ${data.aws_ami_ids.main.ids[0]}"
  source_ami_id     = "${data.aws_ami_ids.main.ids[0]}"
  source_ami_region = "${var.region}"
  encrypted         = true
  kms_key_id        = "${var.kms_key_id}"

  tags = {
    Environment = "Algo"
    "tag:Algo"  = "encrypted"
  }
}

resource "aws_vpc" "main" {
  cidr_block                       = "172.16.0.0/16"
  instance_tenancy                 = "default"
  assign_generated_ipv6_cidr_block = true

  tags = {
    Environment = "Algo"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Environment = "Algo"
  }
}

resource "aws_subnet" "main" {
  vpc_id          = "${aws_vpc.main.id}"
  cidr_block      = "172.16.254.0/23"
  ipv6_cidr_block = "${cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 1)}"

  tags = {
    Environment = "Algo"
  }
}

resource "aws_route_table" "default" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = "${aws_internet_gateway.main.id}"
  }

  tags = {
    Environment = "Algo"
  }
}

resource "aws_route_table_association" "default" {
  subnet_id      = "${aws_subnet.main.id}"
  route_table_id = "${aws_route_table.default.id}"
}

locals {
  services = {
    "icmp" = -1
    "tcp" = 22
    "udp" = 500
    "udp" = 4500
    "udp" = var.wireguard_network["port"]
  }
}

resource "aws_security_group" "main" {
  description = "Enable SSH and IPsec"
  vpc_id      = "${aws_vpc.main.id}"
  tags = {
    Environment = "Algo"
  }

  dynamic "ingress" {
    for_each = [for k, v in local.services : {
      protocol = k
      port = v
    }]

    content {
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      from_port = ingress.value.port
      to_port   = ingress.value.port
      protocol  = ingress.value.protocol
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
  public_key      = "${var.public_key_openssh}"
}

resource "aws_instance" "main" {
  ami                                  = "${var.encrypted == 1 ? join(" ", aws_ami_copy.encrypted.*.id) : data.aws_ami_ids.main.ids[0]}"
  instance_type                        = "${var.size}"
  instance_initiated_shutdown_behavior = "terminate"
  key_name                             = "${aws_key_pair.main.key_name}"
  vpc_security_group_ids               = ["${aws_security_group.main.id}"]
  subnet_id                            = "${aws_subnet.main.id}"
  user_data                            = "${var.user_data}"
  ipv6_address_count                   = 1

  tags = {
    Environment = "Algo"
  }

  volume_tags = {
    Environment = "Algo"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip_association" "main" {
  instance_id   = "${aws_instance.main.id}"
  allocation_id = var.algo_ip
}
