resource "aws_ecr_repository" "app" {
  name                 = "bookyland-app-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = false // update for real
  }
}
