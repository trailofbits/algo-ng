# data "scaleway_image" "main" {
#   architecture = "x86_64"
#   name         = "${var.image}"
# }
#
# resource "scaleway_server" "main" {
#   name  = "${var.algo_name}"
#   image = "${data.scaleway_image.main.id}"
#   type  = "${var.size}"
#   boot_type = "local"
#   enable_ipv6 = true
#   public_ip = "${var.server_address}"
#   state = "running"
#   cloudinit = "${var.user_data}"
#   tags = [
#     "Environment:Algo",
#     "AUTHORIZED_KEY=${replace(var.ssh_public_key, " ", "_"}"
#   ]
#
#   lifecycle {
#     create_before_destroy = true
#   }
# }
