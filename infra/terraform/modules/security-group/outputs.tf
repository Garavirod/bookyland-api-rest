output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}

output "alb_security_group" {
  value = aws_security_group.alb.id
}