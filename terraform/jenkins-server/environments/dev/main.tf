provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr

  subnet_name = var.subnet_name
  subnet_cidr = var.subnet_cidr
  subnet_cidr_2 = var.subnet_cidr_2

  igw_name         = var.igw_name
  route_table_name = var.route_table_name
  sg_name          = var.sg_name
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
  

  source = "../../modules/ec2"

  instance_name = "jenkins-server"
  instance_type = "t3.small"
  ami_id        = data.aws_ami.amazon_linux_2023.id

  subnet_id = module.vpc.subnet_id
  vpc_id    = module.vpc.vpc_id

  key_name = "maria_keypair"

  security_group_id = module.vpc.shared_ec2_sg_id
}