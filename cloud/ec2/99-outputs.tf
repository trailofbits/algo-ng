output "Configuration" {
  value = "configs/${module.cloud-ec2.server_address}/"
}

output "instance_id" {
  value = "${module.cloud-ec2.instance_id}"
}
