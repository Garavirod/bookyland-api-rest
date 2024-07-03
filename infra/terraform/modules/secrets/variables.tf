variable "database_name" {
  type        = string
  sensitive   = true
  description = "Databse name"
}

variable "database_password" {
  type        = string
  sensitive   = true
  description = "Databse password"
}

variable "database_user" {
  type        = string
  sensitive   = true
  description = "Database username"
}