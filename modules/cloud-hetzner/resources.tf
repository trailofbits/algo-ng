resource "random_id" "name" {
  byte_length = 3

  keepers = {
    region_name = "${var.region}/${var.algo_name}"
    user_data   = var.user_data
  }
}

locals {
  algo_name = "${var.algo_name}-${random_id.name.hex}"
}

resource "hcloud_ssh_key" "main" {
  name       = var.algo_name
  public_key = var.ssh_public_key
}

resource "hcloud_server" "main" {
  name        = local.algo_name
  image       = var.image
  server_type = var.size
  location    = var.region
  user_data   = var.user_data
  ssh_keys    = [hcloud_ssh_key.main.id]
  backups     = false
  labels = {
    "Environment" = "Algo"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "hcloud_floating_ip_assignment" "main" {
  floating_ip_id = var.algo_ip
  server_id      = hcloud_server.main.id
}
