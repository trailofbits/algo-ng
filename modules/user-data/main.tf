data "template_file" "cloud_init_vpn" {
  template = "${file("${path.module}/../../scripts/cloud-init.sh")}"
}

data "template_cloudinit_config" "cloud_init" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "main"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.cloud_init_vpn.rendered}"
  }
}
