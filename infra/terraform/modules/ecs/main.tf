resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.application_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([{
    name      = var.container_name
    image     = "${var.ecr_repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/${var.application_name}"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "ecs"
      }
    }
    environment = [{
      name  = "DATABASE_HOST"
      value = var.db_endpoint
    }]
    secrets = [
      {
        name      = "DATABASE_USER_PASSWORD"
        valueFrom = var.secret_db_password_arn
      },
      {
        name      = "DATABASE_NAME"
        valueFrom = var.secret_db_name_arn
      },
      {
        name      = "DATABASE_USER"
        valueFrom = var.secret_db_username_arn
      },
    ]
  }])
}


resource "aws_ecs_service" "main" {
  name            = "${var.application_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets = var.subnets_id
    assign_public_ip = true
    security_groups = [var.ecs_security_group_id]
  }

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  depends_on = [var.lb_listener]
}