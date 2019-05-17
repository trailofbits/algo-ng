resource "hcloud_floating_ip" "main" {
  type          = "ipv4"
  description   = var.algo_name
  home_location = var.region
}

locals {
  server_address = "${hcloud_floating_ip.main.ip_address}"
  algo_config    = "${path.cwd}/configs/${local.server_address}"
}

module "tls" {
  source         = "../../modules/tls/"
  algo_config    = local.algo_config
  vpn_users      = var.vpn_users
  components     = local.components
  server_address = local.server_address
}

module "user-data" {
  source           = "../../modules/user-data/"
  base64_encode    = false
  gzip             = false
  ipv6             = true
  vpn_users        = var.vpn_users
  components       = local.components
  unmanaged        = var.unmanaged
  max_mss          = var.max_mss
  pki              = module.tls.pki
  local_service_ip = local.local_service_ip
  cloud_specific   = <<-EOF
                      #cloud-config
                      write_files:
                        - path: /etc/network/interfaces.d/60-my-floating-ip.cfg
                          permissions: '0644'
                          content: |
                            auto eth0:1
                            iface eth0:1 inet static
                                address ${local.server_address}
                                netmask 32
                      runcmd:
                        - systemctl restart networking
                      EOF
}

module "cloud" {
  source = "../../modules/cloud-hetzner/"
  region = var.region
  algo_name = var.algo_name
  algo_ip = hcloud_floating_ip.main.id
  ssh_public_key = module.tls.ssh_public_key
  user_data = module.user-data.template_cloudinit_config
  server_address = local.server_address
}

module "configs" {
  source = "../../modules/configs/"
  algo_config = local.algo_config
  vpn_users = var.vpn_users
  components = local.components
  ipv6 = true
  server_address = local.server_address
  client_p12_pass = module.tls.client_p12_pass
  ssh_user = module.cloud.ssh_user
  ssh_private_key = module.tls.ssh_private_key
  server_id = module.cloud.server_id
  pki = module.tls.pki
  local_service_ip = local.local_service_ip
  wireguard_network = module.user-data.wireguard_network
  ondemand = local.ondemand
}
