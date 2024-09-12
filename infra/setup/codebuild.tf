########################
# Codebuild definition #
########################

// Deployment for dev
resource "aws_codebuild_project" "deploy_dev" {
  name         = "${var.application_name}-codebuild"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "DOCKERHUB_USER"
      value = "garavirod"
    }

    environment_variable {
      name  = "TF_WORKSPACE"
      value = "$TF_WORKSPACE"
    }

    environment_variable {
      name  = "ECR_URI"
      value = aws_ecr_repository.app.repository_url
    }

    environment_variable {
      name  = "AWS_REGION"
      value = "us-east-1"
    }

    environment_variable {
      name  = "SSM_PARAM_DB_PASSWORD_NAME"
      value = aws_ssm_parameter.database_user_password.name
    }
    environment_variable {
      name  = "SSM_PARAM_DOCKERHUB_TOKEN_NAME"
      value = aws_ssm_parameter.dockerhub_token.name
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}


// Destroy dev infra
/* resource "aws_codebuild_project" "destroy_dev" {
  name         = "${var.application_name}-destroy-infra"
  service_role = aws_iam_role.codebuild_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "TF_WORKSPACE"
      value = "dev"
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec-destroy.yaml")
  }
} */
