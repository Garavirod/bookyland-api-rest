###########################
# CodePipeline Definition #
###########################
resource "aws_codepipeline" "aws_codepipeline" {

  name     = "${var.application_name}-codepipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  # Soruce stage for Dev
  stage {
    name = "Source_Dev"
    action {
      name             = "Source_Dev"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output_dev"]

      configuration = {
        Owner      = var.github_user_name
        Repo       = var.github_repository_name
        Branch     = "dev"
        OAuthToken = var.github_oauthtoken
      }
    }
  }

  # Source stage for prod
  stage {
    name = "Source_Prod"
    action {
      name             = "Source_Prod"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output_prod"]
      configuration = {
        Owner      = var.github_user_name
        Repo       = var.github_repository_name
        Branch     = "prod"
        OAuthToken = var.github_oauthtoken
      }
    }
  }

  # Build stage for Dev
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
        ProjectName = aws_codebuild_project.codebuild.name
      }
    }
  }

  # Build stage for prod
  stage {
    name = "Build_Pord"
    action {
      name             = "Build_Pord"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output_prod"]
      output_artifacts = ["build_output_prod"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuild.name
      }
    }
  }
  artifact_store {
    type     = "s3"
    location = aws_s3_bucket.s3_artifact.bucket
  }
}
