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
     key            = "cluster/terraform.tfstate"
     region         = "us-east-1"
     dynamodb_table = "terraform-lock"
     encrypt        = true
   }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "jenkins" {
  key_name   = "jenkins-key"
  public_key = file("../id_ed25519.pub")
}

# ------------------------------
# Get latest Amazon Linux 2023 AMI
# ------------------------------
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------
# Get VPC and Subnet
# ------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "e-commerce-sys"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# ------------------------------
# Ecommerce Node 1
# ------------------------------
resource "aws_instance" "ecommerce_node1" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ecommerce.id]
  key_name = aws_key_pair.jenkins.key_name
  associate_public_ip_address = true

  tags = {
    Name    = "ecommerce-node1"
    Project = var.project_name
    Role    = "ecommerce-cluster"
  }
}

# ------------------------------
# Ecommerce Node 2
# ------------------------------
resource "aws_instance" "ecommerce_node2" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ecommerce.id]
  key_name = aws_key_pair.jenkins.key_name
  associate_public_ip_address = true

  tags = {
    Name    = "ecommerce-node2"
    Project = var.project_name
    Role    = "ecommerce-cluster"
  }
}
