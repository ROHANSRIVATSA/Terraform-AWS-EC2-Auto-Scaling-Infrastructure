# VPC & NETWORKING RESOURCES

resource "aws_vpc" "dev-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_subnet" "dev-subnet-public-1" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.AWS_REGION}a"

  tags = {
    Name = "dev-subnet-public-1"
  }

  depends_on = [aws_vpc.dev-vpc]
}