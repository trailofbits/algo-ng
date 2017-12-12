data "template_file" "cloud_init_vpn" {
  template = "${file("${path.module}/scripts/cloud-init.sh")}"
  vars {
    git_source        = "${var.git_source}"
    vpn_users         = "${var.vpn_users}"
    ca_password       = "${var.ca_password}"
  }
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
