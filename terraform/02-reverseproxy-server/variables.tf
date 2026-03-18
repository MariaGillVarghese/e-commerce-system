variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for the reverse proxy"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Name of the SSH key pair (must exist in AWS)"
  type        = string
  default     = "jenkins-key"
}

variable "developer_ip" {
  description = "Developer public IP for SSH access (CIDR format)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
  default     = "ecommerce-ha"
}

variable "jenkins_public_key" {
  type        = string
  description = "The public key for the Jenkins server to access the proxy"
}