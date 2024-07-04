variable "application_name" {
  description = "Application name"
  default     = "bookyland"
  type        = string
}
# Secrets RDS
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

variable "db_instance_class" {
  description = "The instance type for the database"
  type        = string
  default     = "db.t3.micro"
}
