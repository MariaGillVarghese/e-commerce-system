terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
     bucket         = "e-commerce-sys"
     key            = "cluster/terraform.tfstate"
     region         = "us-east-1"
     dynamodb_table = "terraform-lock"
     encrypt        = true
   }
}

provider "aws" {
  region = var.aws_region
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

resource "aws_instance" "ecommerce_node1" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ecommerce.id]
  associate_public_ip_address = true

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file(var.private_key_file)
    }

    inline = [
      "mkdir -p /home/ec2-user/.ssh",
      "echo '${file(var.public_key_file)}' >> /home/ec2-user/.ssh/authorized_keys",
      "chown -R ec2-user:ec2-user /home/ec2-user/.ssh",
      "chmod 700 /home/ec2-user/.ssh",
      "chmod 600 /home/ec2-user/.ssh/authorized_keys"
    ]
  }

  tags = {
    Name    = "ecommerce-node1"
    Project = var.project_name
    Role    = "ecommerce-cluster"
  }
}

resource "aws_instance" "ecommerce_node2" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ecommerce.id]
  associate_public_ip_address = true

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file(var.private_key_file)
    }

    inline = [
      "mkdir -p /home/ec2-user/.ssh",
      "echo '${file(var.public_key_file)}' >> /home/ec2-user/.ssh/authorized_keys",
      "chown -R ec2-user:ec2-user /home/ec2-user/.ssh",
      "chmod 700 /home/ec2-user/.ssh",
      "chmod 600 /home/ec2-user/.ssh/authorized_keys"
    ]
  }

  tags = {
    Name    = "ecommerce-node2"
    Project = var.project_name
    Role    = "ecommerce-cluster"
  }
}}
