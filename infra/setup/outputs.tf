# Outputs for easy reference
output "ssm_database_password_arn" {
  description = "The ARN of database password parameter store"
  value       = aws_ssm_parameter.database_user_password.arn
}

output "ssm_databse_password_name" {
  description = "The name of database password parameter store"
  value       = aws_ssm_parameter.database_user_password.name
}
