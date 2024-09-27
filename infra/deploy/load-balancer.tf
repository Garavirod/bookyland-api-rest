#################
# Load Balancer #
#################

/* Load balancer security group */
resource "aws_security_group" "lb" {
  description = "Aplication Load balancer configuration access"
  name        = "${local.prefix}-alb-access"
  vpc_id      = aws_vpc.main.id

  // Rules
  ingress {
    protocol    = "tcp"
    from_port   = 80 // For http
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443 // For https
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 8000 // por where app is running
    to_port     = 8000
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* Aplication Load Balancer */
resource "aws_lb" "alb" {
  name               = "${local.prefix}-alb"
  load_balancer_type = "application" # For ALB
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_groups    = [aws_security_group.lb.id]
}

/* Target group */
resource "aws_lb_target_group" "alb_target_group" {
  name        = "${local.prefix}-alb-target-group"
  protocol    = "HTTP" // Recives https request and they are forwared to http over private subnet
  vpc_id      = aws_vpc.main.id
  target_type = "ip" // Forwards requests to internal ip addresses (Running tasks)
  port        = 8000 // app running port
  health_check {
    path = "/api/health-check/"
  }
}


/* ALB Listener */
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP" // Use https when link a certificate

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}
