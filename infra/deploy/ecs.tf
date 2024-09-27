##########################################
# ECS Cluster for running app on Fargate #
##########################################

/* 
    ECS Task needs permissions for assuming a role (Task role).
    So, task role needs a policy for assumimg a role and such role needs to have permissions for performing jobs.
    The role in question needs to have the necessary permissions to help the task perfom certain aws jobs.
    The permission needs to be defined into a policy and this policy needs to be attached to the task role.
 */

resource "aws_iam_role" "task_execution_role_policy" {
  name               = "${local.prefix}-task-execution-role"
  assume_role_policy = file("./policies/ecs/task-assume-role-policy.json")
}

resource "aws_iam_policy" "task_execution_role_policy" {
  name        = "${local.prefix}-task-exec-role-policy"
  path        = "/"
  description = "Allow ECS retrieve images form ECR and add logs."
  policy      = file("./policies/ecs/task-execution-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role_policy.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}

/* Role to conneting to the running task  via ssm */
resource "aws_iam_role" "app_task" {
  name               = "${local.prefix}-app-task"
  assume_role_policy = file("./policies/ecs/task-assume-role-policy.json")
}

resource "aws_iam_policy" "task_ssm_policy" {
  name        = "${local.prefix}-task-ssm-role-policy"
  path        = "/"
  description = "Policy to allow System Manager to execute in container"
  policy      = file("./policies/ecs/task-ssm-policy.json")
}

resource "aws_iam_role_policy_attachment" "task_ssm_policy" {
  role       = aws_iam_role.app_task.name
  policy_arn = aws_iam_policy.task_ssm_policy.arn
}

/* CloudWatch group */
resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "${local.prefix}-api"
}

/* ECS Cluster */
resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-cluster"
}

/* Task definition */
resource "aws_ecs_task_definition" "api" {
  family                   = "${local.prefix}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_execution_role_policy.arn
  task_role_arn            = aws_iam_role.app_task.arn
  container_definitions = jsonencode([{
    name              = "api"
    image             = var.ecr_app_image
    essential         = true
    memoryReservation = 256
    user              = "root"
    portMappings = [
      {
        containerPort = 8000 // hook with the ALB and SG
        hostPort      = 8000
      }
    ]
    environment = [
      {
        name  = "DATABASE_HOST"
        value = aws_db_instance.main.address
      },
      {
        name  = "DATABASE_NAME"
        value = aws_db_instance.main.db_name
      },
      {
        name  = "DATABASE_USER"
        value = aws_db_instance.main.username
      },
      {
        name  = "DATABASE_USER_PASSWORD"
        value = aws_db_instance.main.password
      },
      {
        name  = "ALLOWED_HOSTS"
        value = "*" // CORS for testing only
        // value = aws_route53_record.app.fqdn # with domain only
      }
    ],
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_task_logs.name
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = "api"
      }
    }
  }])
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64" //important to keep in mind, because this is base on the architecture the docker images are build for.
  }
}

/* Security group */
resource "aws_security_group" "ecs_service" {
  description = "Access rules for the ECS service."
  name        = "${local.prefix}-ecs-service"
  vpc_id      = aws_vpc.main.id

  # Outbound access to endpoints
  egress { // This allow to access the endpoints in private subnet which are in port 443
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # RDS connectivity
  egress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.private_a.cidr_block,
      aws_subnet.private_b.cidr_block,
    ]
  }

  # HTTP inbound access
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // public access
    security_groups = [
      aws_security_group.lb.id // Only accesible for ecs sg
    ]
  }
}

/* ECS */
resource "aws_ecs_service" "api" {
  name                   = "${local.prefix}-api"
  cluster                = aws_ecs_cluster.main.name
  task_definition        = aws_ecs_task_definition.api.family
  desired_count          = 1 // Ability to process more request and to scale up the app, as many as the app needs to handle 
  launch_type            = "FARGATE"
  platform_version       = "1.4.0" // Fargate version
  enable_execute_command = true

  network_configuration {
    assign_public_ip = true

    subnets = [
      # aws_subnet.public_a.id, // private for real appp and public for testing 
      # aws_subnet.public_b.id
      aws_subnet.private_a.id, // resgister the servies in private subnets,, this way ecs task is protected.
      aws_subnet.private_b.id
    ]

    security_groups = [aws_security_group.ecs_service.id]
  }
  // load balcner will forward requests to a target group and tg will forward to proxy container runnning on 8000
  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    container_name   = "api"
    container_port   = 8000
  }
}
