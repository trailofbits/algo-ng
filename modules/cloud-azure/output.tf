output "server_address" {
  value = "${azurerm_public_ip.algo.ip_address}"
}

output "server_id" {
  value = "${azurerm_virtual_machine.algo.id}"
}

output "ssh_user" {
  value = "ubuntu"
}
