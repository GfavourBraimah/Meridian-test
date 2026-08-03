variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance (e.g., Ubuntu 24.04)"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance size"
  type        = string
  default     = "t3.medium" # t2.micro might crash with 4 containers + Postgres!
}

variable "ssh_key_name" {
  description = "The name of the SSH key pair in AWS"
  type        = string
}