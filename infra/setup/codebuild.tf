resource "aws_codebuild_project" "codebuild" {
  name = "${var.application_name}-codebuild"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }
  
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "us-east-1"
    }
    environment_variable {
      name  = "TF_VAR_DATABASE_NAME"
      value = "database_name" # Retrieve from Secrets Manager in buildspec
      type = "SECRETS_MANAGER"
    }
    environment_variable {
      name  = "TF_VAR_DATABASE_USER"
      value = "database_user" # Retrieve from Secrets Manager in buildspec
      type = "SECRETS_MANAGER"
    }
    environment_variable {
      name  = "TF_VAR_DATABASE_USER_PASSWORD"
      value = "database_user_password" # Retrieve from Secrets Manager in buildspec
      type = "SECRETS_MANAGER"
    }
  }

  source {
    type = "GITHUB"
    location = "https://github.com/Garavirod/bookyland-api-rest"
    buildspec = file("buildspec.yaml")
  }
}
