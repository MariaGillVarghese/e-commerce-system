variable "aws_region" { type = string }

variable "vpc_name" { type = string }


variable "ssh_key_name" {
  type = string
}
variable "ec2_instances" {
  default = {
    ec2-1 = {
      name = "e-commerce-dev-ec2-1"
      type = "t3.micro"
    }
    ec2-2 = {
      name = "e-commerce-dev-ec2-2"
      type = "t3.micro"
    }
  
  }
}