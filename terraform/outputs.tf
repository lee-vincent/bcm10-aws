output "head_public_ip" {
  description = "Public IP of head node"
  value       = aws_instance.head.public_ip
}

output "head_private_ip" {
  description = "Private IP of head node"
  value       = aws_instance.head.private_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}
