###################
# Parameter store #
###################

// Random password
resource "random_password" "database_user_password" {
  length           = 16
  special          = true
  override_special = "!@#£$%^&*()-_=+[]{}<>:?"
}

// Secret Managaer definition
resource "aws_ssm_parameter" "database_user_password" {
  name        = "/${var.application_name}/database/user/password"
  description = "Randomly generated database user password"
  type        = "SecureString"
  value       = random_password.database_user_password.result
}

