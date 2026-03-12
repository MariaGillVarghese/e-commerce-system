output "public_ips" {
  description = "Public IPs of EC2 instances"
  value       = aws_instance.this[*].public_ip
}

output "instance_ids" {
  description = "IDs of EC2 instances"
  value       = aws_instance.this[*].id
}

output "private_ips" {
  description = "Private IPs of EC2 instances"
  value       = aws_instance.this[*].private_ip
}
