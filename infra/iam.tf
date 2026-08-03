# iam.tf

# Create the IAM Role for EC2
resource "aws_iam_role" "ec2_ecr_role" {
  name = "meridian_ec2_ecr_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the AWS managed read-only policy for ECR
resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Create the Instance Profile to attach to the EC2 instance
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "meridian_ec2_profile"
  role = aws_iam_role.ec2_ecr_role.name
}