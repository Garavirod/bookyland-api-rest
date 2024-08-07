resource "aws_lb_target_group" "bookyland_tg" {
  name        = "${var.application_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/"
    port                = var.container_port
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = var.load_balancer_arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bookyland_tg.arn
  }
}

/*
  ALB Target Group: It listens on port 8000 and forwards traffic to ECS tasks on the same port.

  ALB Listener: It listens on port 80 (standard HTTP port) and forwards traffic to the target group configured on port 8000.

  ECS Service: It specifies that the FastAPI application within the ECS tasks listens on port 8000, 
  aligning with the target group and ALB configuration.
  By configuring both the ALB and ECS service to use port 8000, 
  you ensure that traffic flows correctly from the ALB through to your FastAPI application running in ECS Fargate.
*/