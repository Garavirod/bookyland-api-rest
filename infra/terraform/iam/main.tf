resource "aws_iam_role" "ec2_ecr_pull_role" {
  name = "ec2_ecr_pull_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "ec2_ecr_pull_policy" {
  name        = "ec2_ecr_pull_policy"
  description = "Policy to allow EC2 instances to pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ecr_pull_policy_attachment" {
  role       = aws_iam_role.ec2_ecr_pull_role.name
  policy_arn = aws_iam_policy.ec2_ecr_pull_policy.arn
}

resource "aws_iam_instance_profile" "ec2_ecr_pull_instance_profile" {
  name = "ec2_ecr_pull_instance_profile"
  role = aws_iam_role.ec2_ecr_pull_role.name
}
