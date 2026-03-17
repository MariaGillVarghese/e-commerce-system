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
     key            = "jenkinsserver/terraform.tfstate"
     region         = "us-east-1"
     dynamodb_table = "terraform-lock"
     encrypt        = true
   }
}

provider "aws" {
  region = var.aws_region
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
# Jenkins EC2 Instance
# ------------------------------
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnet_id
  vpc_security_group_ids = [aws_security_group.jenkins.id]

  associate_public_ip_address = true
  
  tags = {
    Name    = "jenkins-server"
    Project = var.project_name
  }
}
