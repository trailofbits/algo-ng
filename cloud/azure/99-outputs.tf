output "Configuration" {
  value = "configs/${module.cloud-azure.server_address}/"
}

output "instance_id" {
  value = "${module.cloud-azure.server_id}"
}
