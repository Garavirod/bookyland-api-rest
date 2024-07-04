output "aws_lb_target_group_id" {
  value = aws_lb_target_group.bookyland_tg.id
}
output "aws_lb_target_group_arn" {
  value = aws_lb_target_group.bookyland_tg.arn
}

output "load_balancer_listener" {
  value = aws_lb_listener.http.arn
}