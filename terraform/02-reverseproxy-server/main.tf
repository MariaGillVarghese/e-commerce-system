terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "e-commerce-system-maria"
    key            = "reverse-proxy/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------
# Remote State Data Sources
# ---------------------------------------------------------

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "e-commerce-system-maria"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "e-commerce-system-maria"
    key    = "cluster/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ---------------------------------------------------------
# Security Group for Reverse Proxy
# ---------------------------------------------------------

resource "aws_security_group" "proxy_sg" {
  name        = "${var.project_name}-proxy-sg"
  description = "Security group for Nginx Reverse Proxy"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from Developer"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.developer_ip]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-proxy-sg"
    Project = var.project_name
  }
}

# ---------------------------------------------------------
# SECURITY BRIDGE: Allow Proxy to talk to Cluster Nodes
# ---------------------------------------------------------

resource "aws_security_group_rule" "allow_proxy_to_ecommerce" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8082
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.cluster.outputs.ecommerce_security_group_id
  source_security_group_id = aws_security_group.proxy_sg.id
  description              = "Allow traffic from reverse proxy to cluster services"
}

# ---------------------------------------------------------
# Reverse Proxy EC2 Instance
# ---------------------------------------------------------

resource "aws_instance" "reverse_proxy" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = data.terraform_remote_state.vpc.outputs.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.proxy_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name    = "reverse-proxy"
    Project = var.project_name
    Role    = "reverse-proxy"
  }
}

# ---------------------------------------------------------
# Outputs
# ---------------------------------------------------------

output "proxy_public_ip" {
  value = aws_instance.reverse_proxy.public_ip
}

output "proxy_private_ip" {
  value = aws_instance.reverse_proxy.private_ip
}