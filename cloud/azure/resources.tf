resource "azurerm_resource_group" "main" {
  name     = var.algo_name
  location = var.config.clouds.azure.region

  tags = {
    Environment = "Algo"
  }
}

resource "azurerm_public_ip" "main" {
  name                = var.algo_name
  location            = var.config.clouds.azure.region
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"

  tags = {
    Environment = "Algo"
  }
}

locals {
  server_address = azurerm_public_ip.main.ip_address
  algo_config    = "${path.cwd}/configs/${local.server_address}"
}

module "tls" {
  source         = "../../modules/tls/"
  algo_config    = local.algo_config
  vpn_users      = var.config.vpn_users
  server_address = local.server_address
}

module "user-data" {
  source        = "../../modules/user-data/"
  base64_encode = true
  gzip          = true
  ipv6          = false
  config        = local.config
  pki           = module.tls.pki
}

module "cloud" {
  source              = "../../modules/cloud-azure/"
  region              = var.config.clouds.azure.region
  algo_name           = var.algo_name
  algo_ip             = azurerm_public_ip.main.id
  ssh_public_key      = module.tls.ssh_public_key
  user_data           = module.user-data.template_cloudinit_config
  image               = var.config.clouds.azure.image
  size                = var.config.clouds.azure.size
  resource_group_name = azurerm_resource_group.main.name
}

module "configs" {
  source          = "../../modules/configs/"
  algo_config     = local.algo_config
  server_address  = local.server_address
  client_p12_pass = module.tls.client_p12_pass
  ssh_user        = module.cloud.ssh_user
  ssh_private_key = module.tls.ssh_private_key
  server_id       = module.cloud.server_id
  pki             = module.tls.pki
  config          = local.config
}
