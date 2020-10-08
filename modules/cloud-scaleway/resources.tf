data "scaleway_image" "main" {
  architecture = "x86_64"
  name         = var.image
}

locals {
  authorized_key = chomp(replace(var.ssh_public_key, " ", "_"))
}

resource "scaleway_server" "main" {
  name        = var.algo_name
  image       = data.scaleway_image.main.id
  type        = var.size
  boot_type   = "local"
  enable_ipv6 = true
  public_ip   = var.server_address
  state       = "running"
  cloudinit   = var.user_data
  tags = [
    "Environment:Algo",
    "AUTHORIZED_KEY=${local.authorized_key}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}
