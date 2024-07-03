output "secret_datbase_password_arn" {
  value     = aws_secretsmanager_secret.database_password.arn
  sensitive = true
}

output "secret_database_name_arn" {
  value     = aws_secretsmanager_secret.database_name.arn
  sensitive = true
}

output "secret_database_user_arn" {
  value     = aws_secretsmanager_secret.database_user.arn
  sensitive = true
}