provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "jenkins" {
  key_name   = "jenkins-key"
  public_key = file("jenkins_id_rsa.pub")
}

# Data block to get the existing VPC
data "aws_vpc" "ecommerce_vpc" {
  filter {
    name   = "tag:Name"
    values = ["e-commerce-dev-vpc"]
  }
}

# Data block to get the existing Security Group
data "aws_security_group" "ecommerce_sg" {
  filter {
    name   = "group-name"
    values = ["e-commerce-dev-vpc-shared-ec2-sg"]
  }

  vpc_id = data.aws_vpc.ecommerce_vpc.id
}
data "aws_subnets" "ecommerce_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.ecommerce_vpc.id]
  }
}

locals {
  first_subnet_id = data.aws_subnets.ecommerce_subnets.ids[0]
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
module "ec2" {
  for_each = var.ec2_instances

  source = "../../modules/ec2"

  instance_name = each.value.name
  instance_type = each.value.type
  ami_id        = data.aws_ami.amazon_linux_2023.id
  vpc_id            = data.aws_vpc.ecommerce_vpc.id 
  subnet_id        = local.first_subnet_id
  security_group_id = data.aws_security_group.ecommerce_sg.id
  key_name          = "maria_keypair"
}
