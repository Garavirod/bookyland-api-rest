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
    actions = ["s3:GetObject", "s3:PutObject", "S3:DeleteObject", "s3:CreateBucket"]
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
  role       = aws_iam_role.codebuild_role.name
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
      aws_ecr_repository.app.arn
    ]
  }
}

resource "aws_iam_policy" "ecr" {
  name        = "${var.application_name}-ecr"
  description = "Allow CodeBuild to manage ECR"
  policy      = data.aws_iam_policy_document.ecr.json
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.codebuild_role.name
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
  name        = "${var.application_name}-ecs"
  description = "Allow CodeBuild to manage ECS"
  policy      = data.aws_iam_policy_document.codebuild_ecs.json
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.ecs.arn
}

// CodeBuild s3 policy doc for artifacts 
data "aws_iam_policy_document" "s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:PutBucketVersioning",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetBucketPolicy",
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketWebsite"
    ]
    resources = [
      /* "arn:aws:s3:::${aws_s3_bucket.s3_artifact.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.s3_artifact.bucket}/*" */
      "*"
    ]
  }
}
resource "aws_iam_policy" "s3" {
  name        = "${var.application_name}-s3"
  description = "Allow CodeBuild to manage S3"
  policy      = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.s3.arn
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
    resources = ["*"]
  }
}
resource "aws_iam_policy" "logs" {
  name        = "${var.application_name}-logs"
  description = "Allow CodeBuild manage Logs"
  policy      = data.aws_iam_policy_document.logs.json
}
resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.logs.arn
}

// CodeBuild doc policy pass role 
data "aws_iam_policy_document" "pass_role" {
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "pass_role" {
  name        = "${var.application_name}-pass-role"
  description = "Allow CodeBuild pass role"
  policy      = data.aws_iam_policy_document.pass_role.json
}

// CodeBuild doc policy codepipeline
data "aws_iam_policy_document" "codepipeline_codebuild" {
  statement {
    effect    = "Allow"
    actions   = ["codepipeline:StartPipelineExecution"]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "codepipeline" {
  name        = "${var.application_name}-codepipeline"
  description = "Allow CodeBuild project to programmatically start the execution"
  policy      = data.aws_iam_policy_document.codepipeline_codebuild.json
}
resource "aws_iam_role_policy_attachment" "codepipeline_excec" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codepipeline.arn
}

// Parameter store
data "aws_iam_policy_document" "codebuild_parameter_store" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
    ]
    resources = [
      aws_ssm_parameter.database_user_password.arn,
      aws_ssm_parameter.dockerhub_token.arn
    ]
  }
}
resource "aws_iam_policy" "codebuild_parameter_store" {
  name        = "${var.application_name}-codebuild-parameter-store"
  description = "Allow to codebuild manage parameter store"
  policy      = data.aws_iam_policy_document.codebuild_parameter_store.json
}
resource "aws_iam_role_policy_attachment" "codebuild_parameter_store" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_parameter_store.arn
}

# Allow access to retrieve session tokens from STS
resource "aws_iam_policy" "codebuild_sts" {
  name = "${var.application_name}-codebuild-sts"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sts:GetSessionToken",
          "sts:AssumeRole",
          "sts:GetCallerIdentity"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_sts" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_sts.arn
}

# Allow access to EC2 metadata (if your environment requires it)
resource "aws_iam_policy" "codebuild_ec2" {
  name = "${var.application_name}-codebuild-ec2-metadata"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeRegions"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_ec2" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_ec2.arn
}

// Dynamo backend
resource "aws_iam_policy" "codebuild_dynamodb_backend" {
  name = "${var.application_name}-dynamodb-backend"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:dynamodb:*:*:table/${var.tf_state_lock_table}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_dynamodb_backend" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_dynamodb_backend.arn
}


#########################################
# CodePipeline role and iam permissions #
#########################################
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.application_name}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

// S3 artifacts policy permissions
resource "aws_iam_policy" "codebuild_s3" {
  name        = "${var.application_name}-codepipeline-s3"
  description = "Allow codepipeline mange s3 for artifacts"
  policy      = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_role_policy_attachment" "codebuild_s3" {
  role       = aws_iam_role.codepipeline_role.name
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
    resources = ["*"]
  }
}

resource "aws_iam_policy" "codebuild_exec" {
  name        = "${var.application_name}-codepipeline-exec"
  description = "Allow codepipeline to manage Codepipeline executions"
  policy      = data.aws_iam_policy_document.codepipeline_exec.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_exec" {
  role       = aws_iam_role.codepipeline_role.name
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
    resources = ["*"]
  }
}

resource "aws_iam_policy" "codepipeline_ecs" {
  name        = "${var.application_name}-codepiple-ecs"
  description = "Allow codepiple manage ECS"
  policy      = data.aws_iam_policy_document.codebuild_ecs.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_ecs" {
  role       = aws_iam_role.codepipeline_role.name
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
    resources = ["*"]
  }
}

resource "aws_iam_policy" "codepipeline_ecr" {
  name        = "${var.application_name}-codepipeline-ecr"
  description = "Allow codepipeline manage ECR"
  policy      = data.aws_iam_policy_document.codepipeline_ecr.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_ecr" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_ecr.arn
}

// Codestar connection
data "aws_iam_policy_document" "codestar_connection" {
  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.github_connection.arn]
  }
}

resource "aws_iam_policy" "codestar_connection" {
  name        = "${var.application_name}-codepipeline-codestar"
  description = "Allow codepipeline manage CodeStar Connections"
  policy      = data.aws_iam_policy_document.codestar_connection.json
}

resource "aws_iam_role_policy_attachment" "codestar_connection" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codestar_connection.arn
}
