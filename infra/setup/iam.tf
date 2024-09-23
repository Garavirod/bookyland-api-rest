######################################
# Codebuild role and iam permissions #
######################################

// IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_deploy_role" {
  name = "${var.application_name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

// IAM Role for CodeBuild Destroy Role
resource "aws_iam_role" "codebuild_destroy_role" {
  name = "${var.application_name}-codebuild-destroy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
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
data "aws_iam_policy_document" "terraform_backend_policy_doc" {

  version = "2012-10-17"
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.tf_state_bucket}"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${var.tf_state_bucket}/tf-state-deploy/*",
      "arn:aws:s3:::${var.tf_state_bucket}/tf-state-deploy-env/*"
    ]
  }
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:dynamodb:*:*:table/${var.tf_state_lock_table}" # 1th asterisc account, 2d region
    ]
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
  }
}

resource "aws_iam_policy" "terraform_backend_policy_doc" {
  name        = "${var.application_name}-terraform-backend-policy"
  description = "Allow to manage s3 and dynamo backend"
  policy      = data.aws_iam_policy_document.terraform_backend_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "codebuild_deploy_terraform_backend" {
  role       = aws_iam_role.codebuild_deploy_role.name
  policy_arn = aws_iam_policy.terraform_backend_policy_doc.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_destroy_terraform_backend" {
  role       = aws_iam_role.codebuild_destroy_role.name
  policy_arn = aws_iam_policy.terraform_backend_policy_doc.arn
}

/* CodeBuild ECR doc policy  */
resource "aws_iam_role_policy" "codebuild_ecr" {
  role = aws_iam_role.codebuild_deploy_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Resource = [
          aws_ecr_repository.app.arn
        ]
        Action = [
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:ListImages",
          "ecr:DescribeRepositories"
        ]
      },
      {
        Effect = "Allow"
        Resource = [
          "*"
        ]
        Action = [
          "ecr:GetAuthorizationToken"
        ]
      }
    ]
  })
}


// Codebuild ECS doc policy 
data "aws_iam_policy_document" "codebuild_ecs_policy_doc" {
  version = "2012-10-17"
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
    resources = ["*"]
  }
}

resource "aws_iam_policy" "codebuild_ecs_policy" {
  name        = "${var.application_name}-codebuild-ecs"
  description = "Allow ECS management"
  policy      = data.aws_iam_policy_document.codebuild_ecs_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "codebuild_deploy_ecs" {
  role       = aws_iam_role.codebuild_deploy_role.name
  policy_arn = aws_iam_policy.codebuild_ecs_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_destroy_ecs" {
  role       = aws_iam_role.codebuild_destroy_role.name
  policy_arn = aws_iam_policy.codebuild_ecs_policy.arn
}

/* CodeBuild doc policy logs  */
data "aws_iam_policy_document" "codebuild_log_policy_doc" {
  version = "2012-10-17"
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

resource "aws_iam_policy" "codebuild_logs_policy" {
  name        = "${var.application_name}-codebuild-logs"
  description = "Allow CloudWatch logs management"
  policy      = data.aws_iam_policy_document.codebuild_log_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "codebuild_deploy_logs" {
  role       = aws_iam_role.codebuild_deploy_role.name
  policy_arn = aws_iam_policy.codebuild_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_destroy_logs" {
  role       = aws_iam_role.codebuild_destroy_role.name
  policy_arn = aws_iam_policy.codebuild_logs_policy.arn
}


/* Codepipeline role permissions */
// Policy doc
data "aws_iam_policy_document" "codebuild_codepipeline_exe_policy_doc" {
  version = "2012-10-17"
  statement {
    effect    = "Allow"
    actions   = ["codepipeline:StartPipelineExecution"]
    resources = ["*"]
  }
}
// Policy
resource "aws_iam_policy" "codebuild_codepipeline_exe_policy" {
  name        = "${var.application_name}-codebuild-codepipeline-exe"
  description = "Allow codebuild to execute codepipeline"
  policy      = data.aws_iam_policy_document.codebuild_codepipeline_exe_policy_doc.json
}
// Role attachments
resource "aws_iam_role_policy_attachment" "codebuild_deploy_codepipeline_exec" {
  role       = aws_iam_role.codebuild_deploy_role.name
  policy_arn = aws_iam_policy.codebuild_codepipeline_exe_policy.arn
}
resource "aws_iam_role_policy_attachment" "codebuild_destroy_codepipeline_exec" {
  role       = aws_iam_role.codebuild_destroy_role.name
  policy_arn = aws_iam_policy.codebuild_codepipeline_exe_policy.arn
}

/* Parameter store */
resource "aws_iam_role_policy" "codebuild_ssm_parameter_store" {
  role = aws_iam_role.codebuild_deploy_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Resource = [
          aws_ssm_parameter.database_user_password.arn,
          aws_ssm_parameter.dockerhub_token.arn
        ]
        Action = ["ssm:GetParameter"]
      }
    ]
  })
}

/* STS Role permissions */
data "aws_iam_policy_document" "codebuild_sts_policy_doc" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    // Allow access to retrieve session tokens from STS 
    actions = [
      "sts:GetSessionToken",
      "sts:AssumeRole",
      "sts:GetCallerIdentity"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "codebuild_sts_policy" {
  name        = "${var.application_name}-codebuild-sts"
  description = "Allow Codebuild retrive session tokens"
  policy      = data.aws_iam_policy_document.codebuild_sts_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "codebuild_deploy_sts" {
  role       = aws_iam_role.codebuild_deploy_role.name
  policy_arn = aws_iam_policy.codebuild_sts_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_destroy_sts" {
  role       = aws_iam_role.codebuild_destroy_role.name
  policy_arn = aws_iam_policy.codebuild_sts_policy.arn
}


/* Codebuild EC2 role permissions */
data "aws_iam_policy_document" "codebuild_ec2_policy_doc" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [ // Metadata
      "ec2:DescribeInstances",
      "ec2:DescribeRegions"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [ // Networking
      "ec2:DescribeVpcs",
      "ec2:CreateTags",
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:DescribeSecurityGroups",
      "ec2:DeleteSubnet",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DetachInternetGateway",
      "ec2:DescribeInternetGateways",
      "ec2:DeleteInternetGateway",
      "ec2:DetachNetworkInterface",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeRouteTables",
      "ec2:DeleteRouteTable",
      "ec2:DeleteVpcEndpoints",
      "ec2:DisassociateRouteTable",
      "ec2:DeleteRoute",
      "ec2:DescribePrefixLists",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeNetworkAcls",
      "ec2:AssociateRouteTable",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:CreateSecurityGroup",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:CreateVpcEndpoint",
      "ec2:ModifySubnetAttribute",
      "ec2:CreateSubnet",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:CreateInternetGateway",
      "ec2:AttachInternetGateway",
      "ec2:ModifyVpcAttribute",
    "ec2:RevokeSecurityGroupIngress", ]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "codebuild_ec2_policy" {
  name        = "${var.application_name}-codebuild-ec2"
  description = "Allow Codebuild EC2 management"
  policy      = data.aws_iam_policy_document.codebuild_ec2_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "codebuild_deploy_ec2" {
  role       = aws_iam_role.codebuild_deploy_role.name
  policy_arn = aws_iam_policy.codebuild_ec2_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_destroy_ec2" {
  role       = aws_iam_role.codebuild_destroy_role.name
  policy_arn = aws_iam_policy.codebuild_ec2_policy.arn
}


/* S3 artifacts */
data "aws_iam_policy_document" "s3_artifact_policy_doc" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.s3_artifact.bucket}",
      "arn:aws:s3:::${aws_s3_bucket.s3_artifact.bucket}/*"
    ]
  }
}
resource "aws_iam_policy" "s3_artifact_policy" {
  name        = "${var.application_name}-codebuild-s3-artifact"
  description = "Allow s3 management over artifact buckets"
  policy      = data.aws_iam_policy_document.s3_artifact_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "codebuild_deploy_s3_artifact" {
  role       = aws_iam_role.codebuild_deploy_role.name
  policy_arn = aws_iam_policy.s3_artifact_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_destroy_s3_artifact" {
  role       = aws_iam_role.codebuild_destroy_role.name
  policy_arn = aws_iam_policy.s3_artifact_policy.arn
}

#########################################
# CodePipeline role and iam permissions #
#########################################
// Deploy role
resource "aws_iam_role" "codepipeline_deploy_role" {
  name = "${var.application_name}-codepipeline-deploy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}
// Destroy role
resource "aws_iam_role" "codepipeline_destroy_role" {
  name = "${var.application_name}-codepipeline-destroy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

/* Pass role permissions */

// Policy doc
data "aws_iam_policy_document" "pass_role_policy_doc" {
  version = "2012-10-17"
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]
  }
}
// Policy definition
resource "aws_iam_policy" "pass_role_policy" {
  name        = "${var.application_name}-pass-role"
  description = "Allow codepipeline to pass role"
  policy      = data.aws_iam_policy_document.pass_role_policy_doc.json
}
// Poilicy atachments
resource "aws_iam_role_policy_attachment" "codepipeline_deploy_pass_role" {
  role       = aws_iam_role.codepipeline_deploy_role.name
  policy_arn = aws_iam_policy.pass_role_policy.arn
}
resource "aws_iam_role_policy_attachment" "codepipeline_destroy_pass_role" {
  role       = aws_iam_role.codepipeline_destroy_role.name
  policy_arn = aws_iam_policy.pass_role_policy.arn
}

/* S3 artifacts */
// Role policy attachments
resource "aws_iam_role_policy_attachment" "codepipeline_deploy_s3_artifact" {
  role       = aws_iam_role.codepipeline_deploy_role.name
  policy_arn = aws_iam_policy.s3_artifact_policy.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_destroy_s3_artifact" {
  role       = aws_iam_role.codepipeline_destroy_role.name
  policy_arn = aws_iam_policy.s3_artifact_policy.arn
}

/* Codepipeline execution role permissions */

// Doc policy
data "aws_iam_policy_document" "codepipeline_policy_exe_doc" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    resources = [
      aws_codepipeline.deploy.arn,
    ]
    actions = [
      "codepipeline:StartPipelineExecution",
      "codepipeline:GetPipeline",
      "codepipeline:GetPipelineExecution",
      "codepipeline:ListPipelineExecutions",
      "codepipeline:ListPipelines",
      "codepipeline:ListPipelineExecutions",
      "codepipeline:ListPipelineExecutions",
      "codepipeline:ListPipelineExecutionHistory",
    ]
  }
  statement {
    effect = "Allow"
    resources = [
      aws_codebuild_project.deploy_infra.arn,
      aws_codebuild_project.destroy_infra.arn
    ]
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetProjects",
      "codebuild:ListBuilds",
      "codebuild:ListProjects"
    ]
  }
}
// Policy definition
resource "aws_iam_policy" "codepipeline_exe_policy" {
  name        = "${var.application_name}-codepipeline-exe"
  description = "Allow codepipeline management executions"
  policy      = data.aws_iam_policy_document.codepipeline_policy_exe_doc.json
}
// Poilicy atachments
resource "aws_iam_role_policy_attachment" "codepipeline_deploy_exe" {
  role       = aws_iam_role.codepipeline_deploy_role.name
  policy_arn = aws_iam_policy.codepipeline_exe_policy.arn
}
resource "aws_iam_role_policy_attachment" "codepipeline_destroy_exe" {
  role       = aws_iam_role.codepipeline_destroy_role.name
  policy_arn = aws_iam_policy.codepipeline_exe_policy.arn
}


/* Codestar role permissions */
data "aws_iam_policy_document" "codepipeline_codestar_connection_policy_doc" {
  version = "2012-10-17"
  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.github_connection.arn]
  }
}

resource "aws_iam_policy" "codepipeline_codestar_connection_policy" {
  name        = "${var.application_name}-codestar-connection-policy"
  description = "Allow codepipeline codestar connections"
  policy      = data.aws_iam_policy_document.codepipeline_codestar_connection_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_codestar_connection_deploy" {
  role       = aws_iam_role.codepipeline_deploy_role.name
  policy_arn = aws_iam_policy.codepipeline_codestar_connection_policy.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_codestar_connection_destroy" {
  role       = aws_iam_role.codepipeline_destroy_role.name
  policy_arn = aws_iam_policy.codepipeline_codestar_connection_policy.arn
}
