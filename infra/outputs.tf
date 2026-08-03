# outputs.tf

output "ec2_public_ip" {
  description = "The public IP of the Meridian EC2 instance"
  value       = aws_instance.meridian_server.public_ip
}

output "ecr_repository_urls" {
  description = "The URLs of the ECR repositories for GitHub Actions"
  value = {
    frontend = aws_ecr_repository.meridian_frontend.repository_url
    auth     = aws_ecr_repository.meridian_auth.repository_url
    catalog  = aws_ecr_repository.meridian_catalog.repository_url
    orders   = aws_ecr_repository.meridian_orders.repository_url
  }
}


