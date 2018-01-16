output "template_cloudinit_config" {
  value = "${data.template_cloudinit_config.cloud_init.rendered}"
}
