###########################
# CodePipeline Definition #
###########################

// For terraform deployments
resource "aws_codepipeline" "deploy" {

  name     = "${var.application_name}-codepipeline"
  role_arn = aws_iam_role.codepipeline_deploy_role.arn

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
        ProjectName = aws_codebuild_project.deploy_infra.name
      }
    }
  }
  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.s3_artifact.bucket
  }
}

// For terraform destroy
resource "aws_codepipeline" "destroy_pipeline" {
  name     = "${var.application_name}-destroy-pipeline"
  role_arn = aws_iam_role.codepipeline_destroy_role.arn

  stage {
    name = "Source_Destroy"
    action {
      name             = "Source_Dev"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output_destroy"]
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github_connection.arn
        FullRepositoryId = "${var.github_user_name}/${var.github_repository_name}"
        BranchName       = "destroy-manual-trigger"
      }
    }
  }

  stage {
    name = "Destroy"
    action {
      name             = "Destroy_Action"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output_destroy"]
      output_artifacts = []

      configuration = {
        ProjectName = aws_codebuild_project.destroy_infra.name
      }
    }
  }

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.s3_artifact.bucket
  }
}

