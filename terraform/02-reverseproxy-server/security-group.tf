# ------------------------------
# Jenkins Server Security Group
# ------------------------------
resource "aws_security_group" "jenkins" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # SSH access
  ingress {
    description = "SSH from developer"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.developer_ip]
  }

  # Jenkins Web UI
  ingress {
    description = "Jenkins Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.developer_ip]
  }

  # Jenkins agent communication
  ingress {
    description = "Jenkins agents"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = [var.developer_ip]
  }

  # Outbound - allow all
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-jenkins-sg"
    Project = var.project_name
  }
}
