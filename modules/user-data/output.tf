output "template_cloudinit_config" {
  value = data.template_cloudinit_config.cloud_init.rendered
}

output "wireguard_network" {
  value = var.wireguard_network
}

output "local_service_ip" {
  value = var.local_service_ip
}
