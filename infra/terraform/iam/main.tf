/*
ROLES:
  They determine what the identity can and cannot do in AWS.
  Roles are used to grant temporary credentials to entities that need them, ensuring that the permissions are as least-privileged as possible.
  Roles are intended to be assumable by anyone or anything that needs them, such as:
    AWS services (like EC2, Lambda, ECS tasks, etc.)
    Users
    Other AWS accounts
IAM POLICY
  An IAM Policy is a JSON document that defines permissions. These permissions specify which actions are allowed or denied on which AWS resources.

  Policies can be attached to:

    IAM Users
    IAM Groups
    IAM Roles
*/



/*
  Role for ECS Task
    1. Define the Role: This role will be assumed by the ECS tasks running in our cluster.

    2. Attach Policies: Attach the necessary policies to this role. The policies will grant the permissions required by the ECS tasks, 
      such as pulling images from ECR and accessing RDS.
*/
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ec2_ecr_pull_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  /*
    Ensures that ECS has the necessary permissions to manage and run tasks. 
    This includes pulling container images from ECR and writing logs to CloudWatch.
  */
  managed_policy_arns = [ 
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
   ]
}

resource "aws_iam_policy" "ecs_task_policy" { 
  name        = "ecsTaskPolicy"
  description = "Policy for ECS tasks to access necessary services"
  // Permiissions the task can perform once they are runing
  /*
  Provides the running ECS tasks with the permissions they need to perform their specific operations, 
  such as connecting to RDS and accessing secrets from AWS Secrets Manager.
  */
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "rds:DescribeDBInstances",
          "rds:Connect"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_custom_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}