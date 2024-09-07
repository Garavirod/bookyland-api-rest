/* ########################
# Codebuild definition #
########################
resource "aws_codebuild_project" "codebuild" {
  name = "${var.application_name}-codebuild"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }
  
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true

    environment_variable {
      name  = "TF_WORKSPACE"
      value = "$CODEBUILD_WEBHOOK_TRIGGER"
    }

    environment_variable {
      name = "ECR_URI"
      value = aws_ecr_repository.app.repository_url
    }

    environment_variable {
      name = "AWS_REGION"
      value = "us-east-1"
    }

    environment_variable {
      name = "SSM_PARAM_DB_PASSWORD_NAME"
      value = aws_ssm_parameter.database_user_password.name
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("buildspec.yaml")
  }
}
 */
