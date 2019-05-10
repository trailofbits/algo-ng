resource "google_compute_address" "main" {
  name         = var.algo_name
  region       = var.region
  address_type = "EXTERNAL"
}

locals {
  server_address = "${google_compute_address.main.address}"
  algo_config    = "${path.cwd}/configs/${local.server_address}"
}

module "ssh-key" {
  source            = "../../modules/ssh-key/"
  algo_config       = local.algo_config
  ssh_key_algorithm = "RSA"
}

module "tls" {
  source         = "../../modules/tls/"
  algo_config    = local.algo_config
  vpn_users      = var.vpn_users
  components     = var.components
  server_address = local.server_address
}

module "user-data" {
  source         = "../../modules/user-data/"
  ipv6           = false
  vpn_users      = var.vpn_users
  components     = var.components
  unmanaged      = var.unmanaged
  max_mss        = var.max_mss
  pki            = module.tls.pki
}

module "cloud" {
  source             = "../../modules/cloud-gce/"
  region             = var.region
  algo_name          = var.algo_name
  public_key_openssh = module.ssh-key.public_key_openssh
  user_data          = module.user-data.template_cloudinit_config
  server_address = local.server_address
  google_credentials = var.google_credentials
}

# module "configs" {
#   source            = "../../modules/configs/"
#   algo_config       = local.algo_config
#   vpn_users         = var.vpn_users
#   components        = var.components
#   ipv6              = true
#   server_address    = local.server_address
#   client_p12_pass   = module.tls.client_p12_pass
#   ssh_user          = module.cloud.ssh_user
#   private_key       = module.ssh-key.private_key_pem
#   server_id         = module.cloud.server_id
#   pki               = module.tls.pki
#   local_service_ip  = module.user-data.local_service_ip
#   wireguard_network = module.user-data.wireguard_network
#   ondemand          = var.ondemand
# }
