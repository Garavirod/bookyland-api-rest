/* ###########################
# CodePipeline Definition #
###########################
resource "aws_codepipeline" "aws_codepipeline" {
  name = "${var.application_name}-codepipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
 # Stages definition
 stage {
   name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner  = var.github_user_name
        Repo   = var.github_repository_name
        Branch = var.github_branch_name
        OAuthToken = var.github_oauthtoken
      }
   }
 }

 stage {
   name = "Build"
   action {
     name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuild.name
      }
   }
 }

 stage {
   name = "Deploy"
   action {
     name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ECS"
      version          = "1"
      input_artifacts  = ["build_output"]

      configuration = {
        ClusterName   = aws_ecs_cluster.cluster.name
        ServiceName   = aws_ecs_service.service.name
        FileName      = "imagedefinitions.json"
      }
   }
 }
 artifact_store {
   type = "s3"
   location = aws_s3_bucket.s3_artifact.bucket
 }
}


 */
