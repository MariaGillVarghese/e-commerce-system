output "ecommerce_node1_instance_id" {
  description = "Instance ID of ecommerce node 1"
  value       = aws_instance.ecommerce_node1.id
}

output "ecommerce_node1_public_ip" {
  description = "Public IP of ecommerce node 1"
  value       = aws_instance.ecommerce_node1.public_ip
}

output "ecommerce_node1_private_ip" {
  description = "Private IP of ecommerce node 1"
  value       = aws_instance.ecommerce_node1.private_ip
}

output "ecommerce_node2_instance_id" {
  description = "Instance ID of ecommerce node 2"
  value       = aws_instance.ecommerce_node2.id
}

output "ecommerce_node2_public_ip" {
  description = "Public IP of ecommerce node 2"
  value       = aws_instance.ecommerce_node2.public_ip
}

output "ecommerce_node2_private_ip" {
  description = "Private IP of ecommerce node 2"
  value       = aws_instance.ecommerce_node2.private_ip
}

output "ecommerce_security_group_id" {
  description = "Security group ID of the ecommerce cluster"
  value       = aws_security_group.ecommerce.id
}
