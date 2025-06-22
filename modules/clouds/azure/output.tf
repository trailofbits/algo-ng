output "resources" {
  value = {
    server_id = azurerm_virtual_machine.algo.id
    server_ip = azurerm_public_ip.algo4.ip_address
    ssh_user  = "ubuntu"
    ipv6      = local.cloud_config.ipv6
  }
}
