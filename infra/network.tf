# network.tf

# Create the VPC
resource "aws_vpc" "meridian_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Meridian-VPC"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "meridian_igw" {
  vpc_id = aws_vpc.meridian_vpc.id

  tags = {
    Name = "Meridian-IGW"
  }
}

# Create a Public Subnet
resource "aws_subnet" "meridian_public_subnet" {
  vpc_id                  = aws_vpc.meridian_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a" 

  tags = {
    Name = "Meridian-Public-Subnet"
  }
}

# Route Table for the Public Subnet
resource "aws_route_table" "meridian_public_rt" {
  vpc_id = aws_vpc.meridian_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.meridian_igw.id
  }

  tags = {
    Name = "Meridian-Public-RT"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.meridian_public_subnet.id
  route_table_id = aws_route_table.meridian_public_rt.id
}