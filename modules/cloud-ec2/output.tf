output "server_id" {
  value = aws_instance.main.id
}

output "server_address" {
  value = aws_eip.main.public_ip
}

output "ssh_user" {
  value = "ubuntu"
}
