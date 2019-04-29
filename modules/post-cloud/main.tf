provider "random" {
  version = "~> 2.0"
}

resource "random_id" "config" {
  byte_length = 8
}

locals {
  algo_config_tmp = ".tmp/.algo-configs-${random_id.config.hex}/"
  algo_config     = "${path.cwd}/configs/${local.algo_config_tmp}"
}

resource "null_resource" "config-link" {
  provisioner "local-exec" {
    command     = "ln -sf '${local.algo_config_tmp}' '${var.server_address}'"
    working_dir = "configs"
  }

  provisioner "local-exec" {
    command     = "rm '${var.server_address}' || true"
    when        = destroy
    working_dir = "configs"
  }

  provisioner "local-exec" {
    command     = "cd ${local.algo_config_tmp} && rm -rf ./* || true"
    when        = destroy
    working_dir = "configs"
  }

  provisioner "local-exec" {
    command     = "rm -d ${local.algo_config_tmp} || true"
    when        = destroy
    working_dir = "configs"
  }
}
