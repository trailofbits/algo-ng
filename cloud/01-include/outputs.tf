output "Configuration" {
  value = "configs/${local.server_address}/"
}

output "P12_Password" {
  value = module.tls.client_p12_pass
}

output "Server_Address" {
  value = local.server_address
}

output "OnDemand" {
  value = local.ondemand
}

output "Components" {
  value = local.components
}

output "Local_DNS_resolver" {
  value = local.local_service_ip
}
