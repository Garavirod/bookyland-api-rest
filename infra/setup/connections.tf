resource "aws_codestarconnections_connection" "github_connection" {
  name          = "${var.application_name}-github-connection"
  provider_type = "GitHub"
}
