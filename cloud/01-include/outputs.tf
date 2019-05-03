output "Configuration" {
  value = "configs/${local.server_address}/"
}

output "P12_Password" {
  value = module.tls.client_p12_pass
}
