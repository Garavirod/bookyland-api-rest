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

  managed_policy_arns = [ 
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
   ]
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole"
  assume_role_policy = jsonencode({
    Version= "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2-task.amazonaws.com"
      }
    }]
  })

  managed_policy_arns  = [
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
  ]
}