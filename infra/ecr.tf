

resource "aws_ecr_repository" "meridian_frontend" {
  name                 = "meridian-frontend"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true 
  
   image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "meridian_auth" {
  name                 = "meridian-auth"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

   image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "meridian_catalog" {
  name                 = "meridian-catalog"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

   image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "meridian_orders" {
  name                 = "meridian-orders"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

   image_scanning_configuration {
    scan_on_push = true
  }
}