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
resource "aws_iam_role_policy" "codebuild_terraform_backend" {
  role = aws_iam_role.codebuild_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::${var.tf_state_bucket}"]
        Action   = ["s3:ListBucket"]
      },
      {
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.tf_state_bucket}/tf-state-deploy/*",
          "arn:aws:s3:::${var.tf_state_bucket}/tf-state-deploy-env/*"
        ]
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "S3:DeleteObject",
        ]
      },
      {
        Effect = "Allow"
        Resource = [
          "arn:aws:dynamodb:*:*:table/${var.tf_state_lock_table}" # 1th asterisc account, 2d region
        ]
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
      }
    ]
  })
}

// CodeBuild ECR doc policy 
resource "aws_iam_role_policy" "codebuild_ecr" {
  role = aws_iam_role.codebuild_role.name
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
resource "aws_iam_role_policy" "codebuild_ecs" {
  role = aws_iam_role.codebuild_role.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Resource = ["*"]
        Action = [
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
      }
    ]
  })
}

// CodeBuild doc policy logs 
resource "aws_iam_role_policy" "codebuild_logs" {
  role = aws_iam_role.codebuild_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Resource = ["*"]
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      }
    ]
  })
}

// CodeBuild doc policy pass role 
resource "aws_iam_role_policy" "codebuild_pass_role" {
  role = aws_iam_role.codebuild_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Resource = [
          "*"
        ]
        Action = [
          "iam:PassRole",
        ]
      }
    ]
  })
}

// CodeBuild doc policy codepipeline
resource "aws_iam_role_policy" "codebuild_codepipeline" {
  role = aws_iam_role.codebuild_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Resource = ["*"]
        Action   = ["codepipeline:StartPipelineExecution"]
      }
    ]
  })
}

// Parameter store
resource "aws_iam_role_policy" "codebuild_ssm_parameter_store" {
  role = aws_iam_role.codebuild_role.name
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

# Allow access to retrieve session tokens from STS
resource "aws_iam_role_policy" "codebuild_sts" {
  role = aws_iam_role.codebuild_role.name
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

# Allow access to EC2 
resource "aws_iam_role_policy" "codebuild_ec2" {
  role = aws_iam_role.codebuild_role.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { // Metadata
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeRegions"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      { // Networking
        Effect   = "Allow"
        Resource = "*"
        Action = [
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
          "ec2:RevokeSecurityGroupIngress",
        ]
      }
    ]
  })
}

// S3 artifacts
resource "aws_iam_role_policy" "codebuild_s3" {
  role = aws_iam_role.codebuild_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { // For artifacts
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.s3_artifact.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.s3_artifact.bucket}/*"
        ]
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
      }

    ]
  })
}

#########################################
# CodePipeline role and iam permissions #
#########################################
resource "aws_iam_role" "codepipeline_role" {
  name = "${var.application_name}-codepipeline-role"

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

//  S3 policy doc for artifacts 
resource "aws_iam_role_policy" "codepipeline_s3_artifacts" {
  role = aws_iam_role.codepipeline_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.s3_artifact.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.s3_artifact.bucket}/*"
        ]
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
      }
    ]
  })
}


// Codepipeline execution policy permissions
resource "aws_iam_role_policy" "codepipeline_exec" {
  role = aws_iam_role.codepipeline_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Resource = [
          aws_codepipeline.deploy.arn,
        ]
        Action = [
          "codepipeline:StartPipelineExecution",
          "codepipeline:GetPipeline",
          "codepipeline:GetPipelineExecution",
          "codepipeline:ListPipelineExecutions",
          "codepipeline:ListPipelines",
          "codepipeline:ListPipelineExecutions",
          "codepipeline:ListPipelineExecutions",
          "codepipeline:ListPipelineExecutionHistory",
        ]
      },
      {
        Effect   = "Allow"
        Resource = [aws_codebuild_project.deploy_dev.arn]
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetProjects",
          "codebuild:ListBuilds",
          "codebuild:ListProjects"
        ]
      }
    ]
  })
}

// Codestar connection
resource "aws_iam_role_policy" "codepipeline_codestar_connection" {
  role = aws_iam_role.codepipeline_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Resource = [aws_codestarconnections_connection.github_connection.arn]
        Action   = ["codestar-connections:UseConnection"]
      }
    ]
  })
}
