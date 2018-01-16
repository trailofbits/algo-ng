output "server_address" {
  value = "${aws_cloudformation_stack.algo.outputs["ElasticIP"]}"
}
