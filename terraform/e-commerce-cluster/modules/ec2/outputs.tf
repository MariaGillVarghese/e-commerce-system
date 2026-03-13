# ------------------------------
# Ecommerce Cluster Security Group
# ------------------------------
resource "aws_security_group" "ecommerce" {
  name        = "${var.project_name}-ecommerce-sg"
  description = "Security group for ecommerce cluster nodes"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # SSH from developer
  ingress {
    description = "SSH from developer"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.developer_ip]
  }

  # SSH from Jenkins server
  ingress {
    description     = "SSH from Jenkins server"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.jenkins_security_group_id]
  }

  # PostgreSQL - between cluster nodes
  ingress {
    description = "PostgreSQL cluster"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    self        = true
  }

  # Frontend service
  ingress {
    description = "Frontend service"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Order service
  ingress {
    description = "Order service API"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Product service
  ingress {
    description = "Product service API"
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Pacemaker TCP ports
  ingress {
    description = "Pacemaker pcsd"
    from_port   = 2224
    to_port     = 2224
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Pacemaker crmd"
    from_port   = 3121
    to_port     = 3121
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Pacemaker STONITH"
    from_port   = 21064
    to_port     = 21064
    protocol    = "tcp"
    self        = true
  }

  # Corosync UDP ports
  ingress {
    description = "Corosync UDP"
    from_port   = 5404
    to_port     = 5412
    protocol    = "udp"
    self        = true
  }

  # Internal cluster communication - all traffic between cluster nodes
  ingress {
    description = "Internal cluster communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    self        = true
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
    Name    = "${var.project_name}-ecommerce-sg"
    Project = var.project_name
  }
}
