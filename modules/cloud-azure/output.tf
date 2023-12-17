output "server_id" {
  value = azurerm_virtual_machine.algo.id
}

output "server_address" {
  value = azurerm_public_ip.algo4.ip_address
}

output "ssh_user" {
  value = "ubuntu"
}
