########################
# Codebuild definition #
########################

// Deployment for dev
resource "aws_codebuild_project" "deploy_infra" {
  name         = "${var.application_name}-codebuild"
  service_role = aws_iam_role.codebuild_deploy_role.arn

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
      name  = "WORKSPACE"
      value = "dev"
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
resource "aws_codebuild_project" "destroy_infra" {
  name         = "${var.application_name}-destroy"
  service_role = aws_iam_role.codebuild_destroy_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "WORKSPACE"
      value = "dev"
    }

    environment_variable {
      name  = "AWS_REGION"
      value = "us-east-1"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-destroy.yml"
  }
}
