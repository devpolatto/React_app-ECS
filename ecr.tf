
resource "aws_ecr_repository" "repo_ecr" {
  name                 = "react-app"
  image_tag_mutability = "MUTABLE"

  tags = var.common_tags
}