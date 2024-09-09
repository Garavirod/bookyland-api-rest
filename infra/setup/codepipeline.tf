###########################
# CodePipeline Definition #
###########################

// For terraform deployments
resource "aws_codepipeline" "deploy" {

  name     = "${var.application_name}-codepipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  # Dev 
  stage {
    name = "Source_Dev"
    action {
      name             = "Source_Dev"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output_dev"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github_connection.arn
        FullRepositoryId = "${var.github_user_name}/${var.github_repository_name}"
        BranchName       = "dev"
      }
    }
  }

  stage {
    name = "Build_Dev"
    action {
      name             = "Build_Dev"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output_dev"]
      output_artifacts = ["build_output_dev"]

      configuration = {
        ProjectName = aws_codebuild_project.deploy_dev.name
      }
    }
  }
  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.s3_artifact.bucket
  }
}

// For terraform destroy
/* resource "aws_codepipeline" "destroy" {
  name     = "${var.application_name}-codepipeline-destroy"
  role_arn = aws_iam_role.codepipeline_role.arn

  stage {
    name = "Source_Destroy"
    action {
      name             = "Source_Destroy"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_destroy_dev"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github_connection.arn
        FullRepositoryId = "${var.github_user_name}/${var.github_repository_name}"
        BranchName       = "dev"
      }
    }
  }

  stage {
    name = "Approval_Destroy"
    action {
      name     = "Approval_Destroy"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }

  stage {
    name = "Destroy"
    action {
      name            = "DestoryTerraformDeployment"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_destroy_dev"]
      configuration = {
        ProjectName = aws_codebuild_project.destroy_dev.name
      }
    }
  }
  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.s3_artifact.bucket
  }
} */

