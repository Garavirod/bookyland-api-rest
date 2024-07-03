resource "aws_lb" "bookyland_load_balancer" {
  name               = "bookyland-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_ecs_id]
  subnets            = var.public_subnets_id
}