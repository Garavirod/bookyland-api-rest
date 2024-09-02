#########################################
# CodePipeline role and iam permissions #
#########################################
resource "aws_iam_role" "codepipeline_role" {
  name = "${var.application_name}-codepipeline-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
// S3 artifacts policy permissions
data "aws_iam_policy_document" "codepipeline_s3" {
  statement {
    effect = "Allow"
    actions = [ 
      "s3:GetObject",
      "s3:PutObject",
      "s3:GetBucketLocation" 
    ]
    resources = [ "*" ]
  }
}

resource "aws_iam_policy" "codebuild_s3" {
  name = "${var.application_name}-codepipeline-s3"
  description = "Allow codepipeline mange s3 for artifacts"
  policy = data.aws_iam_policy_document.codepipeline_s3.json
}

resource "aws_iam_role_policy_attachment" "codebuild_s3" {
  role = aws_iam_role.codepipeline_role.arn
  policy_arn = aws_iam_policy.codebuild_s3.arn
}
// Codepipeline policy permissions
data "aws_iam_policy_document" "codepipeline_exec" {
  statement {
    effect = "Allow"
    actions = [ 
      "codepipeline:StartPipelineExecution",
      "codepipeline:GetPipeline",
      "codepipeline:GetPipelineExecution",
      "codepipeline:ListPipelineExecutions",
      "codepipeline:ListPipelines",
      "codepipeline:ListPipelineExecutions",
      "codepipeline:ListPipelineExecutions",
      "codepipeline:ListPipelineExecutionHistory",
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetProjects",
      "codebuild:ListBuilds",
      "codebuild:ListProjects"
     ]
    resources = [ "*" ]
  }
}

resource "aws_iam_policy" "codebuild_exec" {
  name = "${var.application_name}-codepipeline-exec"
  description = "Allow codepipeline to manage Codepipeline executions"
  policy = data.aws_iam_policy_document.codepipeline_exec.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_exec" {
  role = aws_iam_role.codepipeline_role.arn
  policy_arn = aws_iam_policy.codebuild_exec.arn
}
// Codepipeline ECS permissions
data "aws_iam_policy_document" "codepipeline_ecs" {
  statement {
    effect = "Allow"
    actions = [ 
        "ecs:DescribeClusters",
        "ecs:DescribeServices",
        "ecs:UpdateService",
        "ecs:RegisterTaskDefinition"
     ]
     resources = [ "*" ]
  }
}

resource "aws_iam_policy" "codepipeline_ecs" {
  name = "${var.application_name}-codepiple-ecs"
  description = "Allow codepiple manage ECS"
  policy = data.aws_iam_policy_document.codebuild_ecs.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_ecs" {
  role = aws_iam_role.codepipeline_role.arn
  policy_arn = aws_iam_policy.codepipeline_ecs.arn
}
// ECR Permissions
data "aws_iam_policy_document" "codepipeline_ecr" {
  statement {
    effect = "Allow"
    actions = [ 
       "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:GetAuthorizationToken",
     ]
     resources = [ "*" ]
  }
}

resource "aws_iam_policy" "codepipeline_ecr" {
  name = "${var.application_name}-codepipeline-ecr"
  description = "Allow codepipeline manage ECR"
  policy = data.aws_iam_policy_document.codepipeline_ecr.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_ecr" {
  role = aws_iam_role.codepipeline_role.arn
  policy_arn = aws_iam_policy.codepipeline_ecr.arn
}


###########################
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
        Branch = "main"
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


