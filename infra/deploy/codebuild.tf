######################################
# Codebuild role and iam permissions #
######################################

// IAM role for codebuild
resource "aws_iam_role" "codebuild_role" {
  name = "${var.application_name}-codebuild-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}
// Policy for terraform backend to s3 and Dynamo access 
data "aws_iam_policy_document" "tf_backend" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.tf_state_bucket}"]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "S3:DeleteObject"]
    resources = [
      "arn:aws:s3:::${var.tf_state_bucket}/tf-state-deploy/*",
      "arn:aws:s3:::${var.tf_state_bucket}/tf-state-deploy-env/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    # Fisrt asterisc for account and second one for region
    resources = [
      "arn:aws:dynamo:*:*:table/${var.tf_state_lock_table}"
    ]
  }
}
resource "aws_iam_policy" "tf_backend" {
  name        = "${var.application_name}-codebuild-tf-s3-dynamo"
  description = "Allow CodeBuild to use s3 and dynamo as backend state and lock"
  policy      = data.aws_iam_policy_document.tf_backend.json
}

resource "aws_iam_role_policy_attachment" "tf_backend" {
  role = aws_iam_role.codebuild_role.arn
  policy_arn = aws_iam_policy.tf_backend.arn
}
// CodeBuild ECR doc policy 
data "aws_iam_policy_document" "ecr" {
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage"
    ]
    resources = [
      aws_ecr_repository.app.arn,
      aws_ecr_repository.proxy.arn
    ]
  }
}

resource "aws_iam_policy" "ecr" {
  name = "${var.application_name}-ecr"
  description = "Allow CodeBuild to manage ECR"
  policy = data.aws_iam_policy_document.ecr.json
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role = aws_iam_role.codebuild_role.arn
  policy_arn = aws_iam_policy.ecr.arn
}
// Codebuild ECS doc policy 
data "aws_iam_policy_document" "codebuild_ecs" {
  statement {
    effect = "Allow"
    actions = [ 
      "ecs:DescribeClusters",
      "ecs:DeregisterTaskDefinition",
      "ecs:DeleteCluster",
      "ecs:DescribeServices",
      "ecs:UpdateService",
      "ecs:DeleteService",
      "ecs:DescribeTaskDefinition",
      "ecs:CreateService",
      "ecs:RegisterTaskDefinition",
      "ecs:CreateCluster",
      "ecs:UpdateCluster",
      "ecs:TagResource",
     ]
    resources = [ 
      "*"
     ]
  }
}
resource "aws_iam_policy" "ecs" {
  name = "${var.application_name}-ecs"
  description = "Allow CodeBuild to manage ECS"
  policy = data.aws_iam_policy_document.codebuild_ecs.json
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role = aws_iam_role.codebuild_role.arn
  policy_arn = aws_iam_policy.ecs.arn
}
// CodeBuild s3 policy doc for artifacts 
data "aws_iam_policy_document" "s3" {
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
resource "aws_iam_policy" "s3_artifacts" {
  name = "${var.application_name}-s3-artifacts"
  description = "Allow CodeBuild to manage S3 artifacts"
  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_role_policy_attachment" "s3_artifacts" {
  role = aws_iam_role.codebuild_role.arn
  policy_arn = aws_iam_policy.s3_artifacts.arn
}
// CodeBuild doc policy logs 
data "aws_iam_policy_document" "logs" {
  statement {
    effect = "Allow"
    actions = [ 
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
     ]
  }
}
resource "aws_iam_policy" "logs" {
  name = "${var.application_name}"
  description = "Allow CodeBuild manage Logs"
  policy = data.aws_iam_policy_document.logs.json
}
resource "aws_iam_role_policy_attachment" "logs" {
  role = aws_iam_role.codebuild_role.arn
  policy_arn = aws_iam_policy.logs.arn
}
// CodeBuild doc policy pass role #
data "aws_iam_policy_document" "pass_role" {
  statement {
    effect = "Allow"
    actions = [ 
                "iam:PassRole",
     ]
     resources = [ "*" ]
  }
}
resource "aws_iam_policy" "pass_role" {
  name = "${var.application_name}"
  description = "Allow CodeBuild pass role"
  policy = data.aws_iam_policy_document.pass_role.json
}
// CodeBuild doc policy codepipeline
data "aws_iam_policy_document" "codepipeline_codebuild" {
  statement {
    effect = "Allow"
    actions = [ "codepipeline:StartPipelineExecution" ]
    resources = [ "*" ]
  }
}
resource "aws_iam_policy" "codepipeline" {
  name = "${var.application_name}-codepipeline"
  description = "Allow CodeBuild project to programmatically start the execution"
  policy = data.aws_iam_policy_document.codepipeline_codebuild.json
}
resource "aws_iam_role_policy_attachment" "codepipeline_excec" {
  role = aws_iam_role.codebuild_role.arn
  policy_arn = aws_iam_policy.codepipeline.arn
}
// Parameter store
data "aws_iam_policy_document" "codebuild_parameter_store" {
  statement {
    effect = "Allow"
    actions = [ 
       "ssm:GetParameter",
     ]
  }
}
resource "aws_iam_policy" "codebuild_parameter_store" {
  name = "${var.application_name}-codebuild-parameter-store"
  description = "Allow to codebuild manage parameter store"
  policy = data.aws_iam_policy_document.codebuild_parameter_store.json
}
resource "aws_iam_role_policy_attachment" "codebuild_parameter_store" {
  role = aws_iam_role.codebuild_role.arn
  policy_arn = aws_iam_policy.codebuild_parameter_store.arn
}

########################
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
  }

  source {
    type = "GITHUB"
    location = var.github_url_repo
    buildspec = file("buildspec.yaml")
  }
}
