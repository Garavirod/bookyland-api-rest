resource "aws_lb" "bookyland_load_balancer" {
  name               = "${var.application_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnets_id
}