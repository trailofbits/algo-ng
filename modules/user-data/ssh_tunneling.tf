data "template_file" "ssh_tunneling" {
  template = "${file("${path.module}/cloud-init/012-ssh_tunneling.yml")}"
}

data "template_file" "ssh_tunneling-users" {
  count    = "${length(var.vpn_users)}"
  template = "${file("${path.module}/cloud-init/012-ssh_tunneling-users.yml")}"
  vars {
    user                = "${element(var.vpn_users, count.index)}"
    public_key_openssh  = "${element(var.clients_public_key_openssh, count.index)}"
  }
}

data "template_file" "end" {
  template = "${file("${path.module}/cloud-init/099-end.yml")}"
}
