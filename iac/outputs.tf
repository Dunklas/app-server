output "server_ip" {
  value = aws_eip.ip.public_ip
}

output "registry_url" {
  value = aws_ecr_repository.ecr_registry.repository_url
}
