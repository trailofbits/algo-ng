output "server_address" {
  value = "${azurerm_public_ip.algo.ip_address}"
}
