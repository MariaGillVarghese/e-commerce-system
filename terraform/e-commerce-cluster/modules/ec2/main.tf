resource "aws_key_pair" "jenkins" {
  key_name   = "jenkins-key"
  public_key = file("~/.ssh/id_rsa.pub")  # Path to public key on Jenkins server
}

resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id = var.subnet_id

  associate_public_ip_address = true

  vpc_security_group_ids = [var.security_group_id]

  key_name = aws_key_pair.jenkins.key_name

  tags = {
    Name = var.instance_name
  }
}
