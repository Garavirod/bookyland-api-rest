resource "aws_secretsmanager_secret" "database_name" {
  name        = "bookyland/database_name"
  description = "Database name for Bookyland"
}

resource "aws_secretsmanager_secret_version" "database_name_version" {
  secret_id     = aws_secretsmanager_secret.database_name.id
  secret_string = var.database_name
}

resource "aws_secretsmanager_secret" "database_user" {
  name        = "bookyland/database_user"
  description = "Database user for Bookyland"
}

resource "aws_secretsmanager_secret_version" "database_user_version" {
  secret_id     = aws_secretsmanager_secret.database_user.id
  secret_string = var.database_user
}

resource "aws_secretsmanager_secret" "database_password" {
  name        = "bookyland/database_password"
  description = "Database password for Bookyland"
}

resource "aws_secretsmanager_secret_version" "database_password_version" {
  secret_id     = aws_secretsmanager_secret.database_password.id
  secret_string = var.database_password
}