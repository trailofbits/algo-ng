output "server_id" {
  value = "${azurerm_virtual_machine.algo.id}"
}

output "ssh_user" {
  value = "ubuntu"
}
