provider "random" {
  version = "~> 2.0"
}

resource "random_id" "config" {
  byte_length = 8
}

locals {
  algo_config_tmp = ".tmp/.algo-configs-${random_id.config.hex}/"
  algo_config     = "configs/${local.algo_config_tmp}"
  server_address  = "${module.cloud-gce.server_address}"
}

resource "null_resource" "config" {
  provisioner "local-exec" {
    command = "mkdir -p '${local.algo_config}/keys'"
  }
}

resource "null_resource" "config-link" {
  provisioner "local-exec" {
    command     = "ln -sf '${local.algo_config_tmp}' '${local.server_address}'"
    working_dir = "configs"
  }

  provisioner "local-exec" {
    command     = "rm '${local.server_address}' || true"
    when        = "destroy"
    working_dir = "configs"
  }
}
