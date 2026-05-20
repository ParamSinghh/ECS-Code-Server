resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"
  # Force delete even if the repository contains images
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}