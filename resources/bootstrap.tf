locals {
  name       = "algo-${terraform.workspace}"
  config     = yamldecode(file("${path.cwd}/config.yaml"))
  local_path = "${path.cwd}/configs/${terraform.workspace}"

  module_init      = module.init.resources
  module_cloud     = module.cloud.resources
  module_bootstrap = module.bootstrap.resources

  dns = local.config.dns.encryption.enabled || local.config.dns.adblocking.enabled ? {
    ipv4 = [local.module_init.service_ip.ipv4]
    ipv6 = [local.module_init.service_ip.ipv6]
    } : {
    ipv4 = local.config.dns.resolvers.ipv4
    ipv6 = local.config.dns.resolvers.ipv6
  }
}

module "init" {
  source     = "../../modules/init/"
  local_path = local.local_path
}

module "bootstrap" {
  source       = "../../modules/bootstrap/"
  algo_config  = local.config
  ssh_key      = local.module_init.ssh_key
  cloud_config = local.module_cloud
  init_config  = local.module_init

  triggers = {
    server_id = local.module_cloud.server_id
  }
}

module "local-configs" {
  source       = "../../modules/local-configs/"
  algo_config  = local.config
  resources    = local.module_bootstrap
  cloud_config = local.module_cloud
  local_path   = local.local_path
  dns          = local.dns

}

output "congrats" {
  value = {
    message = <<-EOF
      #                          Congratulations!                            #
      #                     Your Algo server is running.                     #
      #    Config files and certificates are in the ./configs/ directory.    #
      #              Go to https://ipleak.net/ after connecting              #
      #        and ensure that all your traffic passes through the VPN.      #
    EOF

    config = {
      "DNS resolvers" = concat(local.dns.ipv4, local.dns.ipv6)
      "Cloud config"  = local.module_cloud
    }
  }
  sensitive = false
}
