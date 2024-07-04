variable "vpc_id" {
  description = "bookyland VPC id"
  type        = string
}

variable "subnets_id" {
  description = "Subnets IDs"
  type        = list(string)
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR respository URL"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of task role"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of execution role"
  type        = string
}

variable "secret_db_name_arn" {
  description = "Secret database name arn"
  type        = string
}

variable "secret_db_username_arn" {
  description = "The secret username arn for the database"
  type        = string
}
variable "db_endpoint" {
  description = "The endpoint of the RDS instance"
  type        = string
}

variable "secret_db_password_arn" {
  description = "The secret password arn for the database"
  type        = string
  sensitive   = true
}

variable "ecs_security_group_id" {
  description = "ECS security group"
}

variable "lb_target_group_arn" {

}

variable "lb_listener" {

}

variable "application_name" {
  description = "Application name"
  default     = "bookyland"
  type        = string
}

variable "container_port" {

}
variable "container_name" {

}