resource "aws_ecs_cluster" "main" {
  name = var.cluster.name
}

resource "aws_ecs_task_definition" "main" {
  family = "fast-api-task"
  network_mode = "awsvpc"
  requires_compatibilities = [ "FARGATE" ]
  cpu = "256"
  memory = "512"
  execution_role_arn = var.execution_role_arn
  task_role_arn = var.task_role_arn

  container_definitions = jsonencode([{
    name = "bookyland-rest-api-app"
    image = "${var.ecr_repository_url}:latest"
    essential = true
    portMapping = [{
        containerPort = 8000
        hostPort = 8000
    }]
    environment = [{
      name  = "DB_HOST"
      value = var.db_endpoint
    }, {
      name  = "DB_NAME"
      value = var.db_name
    }, {
      name  = "DB_USER"
      value = var.db_username
    }, {
      name  = "DB_PASSWORD"
      value = var.db_password
    }]
  }])
}


resource "aws_ecs_service" "main" {
  name = "fastapi-bookyland-service"
  cluster = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count = 1
  launch_type = "FARGATE"
  network_configuration {
    subnets = var.subnets_id
    assign_public_ip = true
    security_groups = [aws_security_group.ecs.id]
  }
}