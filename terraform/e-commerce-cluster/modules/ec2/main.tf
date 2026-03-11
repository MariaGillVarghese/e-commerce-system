# Create multiple EC2s
resource "aws_instance" "this" {
  count           = 2  # example: two instances
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.security_group_id]

  key_name = var.key_name

  tags = {
    Name = "${var.instance_name}-${count.index + 1}"
  }
}
