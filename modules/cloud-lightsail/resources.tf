resource "random_id" "resource_name" {
  byte_length = 8
}

locals {
  algo_name = "${var.algo_name}-${random_id.resource_name.hex}"
}

resource "aws_lightsail_key_pair" "main" {
  name       = "${local.algo_name}-key"
  public_key = "${var.public_key_openssh}"
}

resource "aws_lightsail_instance" "main" {
  name              = "${local.algo_name}-server"
  availability_zone = "${var.region}a"
  blueprint_id      = "${var.image}"
  bundle_id         = "${var.size}"
  key_pair_name     = "${aws_lightsail_key_pair.main.id}"
  # user_data         = "${var.user_data}"
}

resource "aws_lightsail_static_ip" "main" {
  name = "${local.algo_name}-ip"
}

resource "aws_lightsail_static_ip_attachment" "main" {
  static_ip_name  = "${aws_lightsail_static_ip.main.name}"
  instance_name   = "${aws_lightsail_instance.main.name}"
}
