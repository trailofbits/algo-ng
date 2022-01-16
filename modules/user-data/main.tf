data "template_cloudinit_config" "user_data" {
  gzip          = var.gzip
  base64_encode = var.base64_encode

  part {
    filename     = "algo.sh"
    content_type = "text/x-shellscript"
    content      = templatefile("${path.module}/files/user-data.sh", {})
  }
}

output "user_data" {
  value = data.template_cloudinit_config.user_data.rendered
}
