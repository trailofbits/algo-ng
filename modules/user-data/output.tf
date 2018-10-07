output "template_cloudinit_config" {
  value = "${data.template_cloudinit_config.cloud_init.rendered}"
}

output "wg_users_private" {
  value = ["${random_string.wg_user.*.result}"]
}

output "wg_users_public" {
  value = ["${random_string.wg_user.*.result}"]
}

output "wireguard_network" {
  value = "${var.wireguard_network}"
}

output "local_service_ip" {
  value = "${var.local_service_ip}"
}
