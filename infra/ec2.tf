

resource "aws_instance" "meridian_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.meridian_public_subnet.id
  vpc_security_group_ids = [aws_security_group.meridian_sg.id]
  key_name               = var.ssh_key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name


  user_data = file("${path.module}/../scripts/server_setup.sh")

  # Add some extra storage just in case the database and Docker images get heavy
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }


  tags = {
    Name        = "Meridian-Retail-Prod"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}



# 1. Allocate a Static Elastic IP and attach it to the EC2 instance
resource "aws_eip" "meridian_eip" {
  instance = aws_instance.meridian_server.id
  domain   = "vpc" 

  tags = {
    Name        = "Meridian-Static-IP"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}