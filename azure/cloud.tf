module "cloud" {
  source      = "../../modules/clouds/azure/"
  algo_config = local.config
  deploy_id   = local.module_init.deploy_id
  ssh_key     = local.module_init.ssh_key
  user_data   = local.module_init.user_data

  providers = {
    azurerm = azurerm
  }
}

provider "azurerm" {
  subscription_id                 = local.config.clouds.azure.subscription_id
  resource_provider_registrations = "none"

  features {}
}
