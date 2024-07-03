variable "ecr_repository_arn" {
  description = "ARN ECR for granting access"
  type        = string
}

/* variable "secretsmanager_database_host_arn" {
  type = string
}
 */
variable "secretsmanager_database_name_arn" {
  type = string
}

variable "secretsmanager_database_user_arn" {
  type = string
}

variable "secretsmanager_database_password_arn" {
  type = string
}

/* variable "secretsmanager_database_port_arn" {
  type = string
} */