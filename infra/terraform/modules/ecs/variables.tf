variable "vpc_id" {
  description = "bookyland VPC id"
  type = string
}

variable "subnets_id" {
  description = "Subnets IDs"
  type = list(string)
}

variable "cluster_name" {
  description = "ECS cluster name"
  type = string
}

variable "ecr_repository_url" {
  description = "ECR respository URL"
  type = string
}

variable "task_role_arn" {
  description = "ARN of task role"
  type = string
}

variable "execution_role_arn" {
  description = "ARN of execution role"
  type = string
}

variable "db_name" {
  description = "database name"
  type = string
}

variable "db_username" {
  description = "The username for the database"
  type        = string
}
variable "db_endpoint" {
  description = "The endpoint of the RDS instance"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}