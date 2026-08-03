# security.tf

# 1. Automatically fetch your current public IP address
data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "aws_security_group" "meridian_sg" {
  name        = "meridian-web-sg"
  description = "Allow HTTP, HTTPS for customers, and restricted SSH for admin"
  vpc_id      = aws_vpc.meridian_vpc.id

  # Allow HTTP (Port 80) - Must be open to the world so customers can visit the site
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS (Port 443) - Must be open to the world for secure checkout
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH (Port 22) - Locked down STRICTLY to your dynamic IP!
  # The chomp() function removes any hidden newlines from the API response
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Meridian-Security-Group"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
