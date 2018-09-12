
# data "template_file" "stack" {
#   template = "${file("${path.module}/files/stack.yml")}"
#   vars {
#     InstanceType        = "${var.size}"
#     ImageId             = "${data.aws_ami_ids.ubuntu.ids[0]}"
#     UserData            = "${data.template_cloudinit_config.config.rendered}"
#     public_key_openssh  = "${var.public_key_openssh}"
#     algo_name           = "${var.algo_name}"
#     region              = "${var.region}"
#   }
# }

# resource "aws_cloudformation_stack" "algo" {
#   name              = "${var.algo_name}"
#   disable_rollback  = true
#   template_body     = "${data.template_file.stack.rendered}"
#   tags {
#     Environment     = "Algo"
#   }
# }
