variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for ecommerce nodes"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "e-commerce-key-pair"
}

variable "developer_ip" {
  description = "Developer public IP for SSH access (CIDR format, e.g. 1.2.3.4/32). Use 0.0.0.0/0 for development."
  type        = string
  default     = "0.0.0.0/0"
}

variable "jenkins_security_group_id" {
  description = "Security group ID of the Jenkins server (for SSH access)"
  type        = string
  default     = "sg-00dd23f0dd812ed2e"
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
  default     = "ecommerce-ha"
}
