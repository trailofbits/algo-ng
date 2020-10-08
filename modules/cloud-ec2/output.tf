output "server_id" {
  value = aws_instance.main.id
}

output "ssh_user" {
  value = "ubuntu"
}
