data "template_file" "cloud_init_vpn" {
  template = "${file("${path.module}/cloud-init/main.sh")}"
  vars {
    git_source        = "${var.git_source}"
    deploy_playbook   = "${var.deploy_playbook}"
    vpn_users         = "${join(",", var.vpn_users)}"
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
