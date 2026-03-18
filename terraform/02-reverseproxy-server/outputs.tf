output "jenkins_instance_id" {
  description = "Instance ID of the Jenkins server"
  value       = aws_instance.jenkins.id
}

output "jenkins_public_ip" {
  description = "Public IP of the Jenkins server"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_public_dns" {
  description = "Public DNS of the Jenkins server"
  value       = aws_instance.jenkins.public_dns
}

output "jenkins_security_group_id" {
  description = "Security group ID of the Jenkins server"
  value       = aws_security_group.jenkins.id
}
