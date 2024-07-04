resource "aws_ecr_repository" "main" {
  name = "${var.application_name}-ecr"
}