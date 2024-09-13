# Outputs for easy reference
output "ssm_database_password_arn" {
  description = "The ARN of database password parameter store"
  value       = aws_ssm_parameter.database_user_password.arn
}

output "ssm_databse_password_name" {
  description = "The name of database password parameter store"
  value       = aws_ssm_parameter.database_user_password.name
}

output "ssm_dockerhub_token" {
  description = "The name of docker hub parameter store"
  value       = aws_ssm_parameter.dockerhub_token.name
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}
