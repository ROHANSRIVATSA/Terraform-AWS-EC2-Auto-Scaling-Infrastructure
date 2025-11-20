# NETWORKING RESOURCES - Internet Gateway, Route Tables, Security Groups

resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "dev-igw"
  }

  depends_on = [aws_vpc.dev-vpc]
}

resource "aws_route_table" "dev-public-crt" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.dev-igw.id
  }

  tags = {
    Name = "dev-public-crt"
  }

  depends_on = [aws_internet_gateway.dev-igw]
}

resource "aws_route_table_association" "dev-crta-public-subnet-1" {
  subnet_id      = aws_subnet.dev-subnet-public-1.id
  route_table_id = aws_route_table.dev-public-crt.id
}


# SECURITY GROUP - SSH & HTTP Access

resource "aws_security_group" "ssh-allowed" {
  name_prefix = "ssh-http-sg-"
  description = "Security group for SSH and HTTP access"
  vpc_id      = aws_vpc.dev-vpc.id

  # Egress: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress: SSH (Port 22) - IMPORTANT: Restrict this in production!
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access - restrict to your IP in production"
  }

  # Ingress: HTTP (Port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # Ingress: HTTPS (Port 443) - for future use
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  tags = {
    Name = "ssh-http-security-group"
  }

  depends_on = [aws_vpc.dev-vpc]
}