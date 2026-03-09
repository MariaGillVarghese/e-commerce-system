resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "this" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.subnet_cidr
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true   # ✅ THIS IS THE FIX

  tags = {
    Name = var.subnet_name
  }
}
resource "aws_subnet" "this_2" {
  vpc_id            = aws_vpc.this.id
  cidr_block = var.subnet_cidr_2
  availability_zone = "us-east-1b"

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.subnet_name}-2"
  }
}

# ✅ Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.igw_name
  }
}

# ✅ Route Table
resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.route_table_name
  }
}


# ✅ Default Route to Internet
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# ✅ Associate Subnet with Route Table
resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}
resource "aws_route_table_association" "this_2" {
  subnet_id      = aws_subnet.this_2.id
  route_table_id = aws_route_table.this.id
}
resource "aws_security_group" "shared_ec2_sg" {
  name        = "${var.vpc_name}-shared-ec2-sg"
  description = "Shared SG for all EC2 cluster nodes"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Cluster communication
  ingress {
    description = "Cluster TCP 2224"
    from_port   = 2224
    to_port     = 2224
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Cluster TCP 3121"
    from_port   = 3121
    to_port     = 3121
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Cluster TCP 21064"
    from_port   = 21064
    to_port     = 21064
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Cluster UDP 5405"
    from_port   = 5405
    to_port     = 5405
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "for frontend service"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "Database"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "order service"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "product service"
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Jenkins"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
}


