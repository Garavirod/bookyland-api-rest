variable "application_name" {
  description = "Application name for taging resources"
  default     = "bookyland"
  type        = string
}

variable "contact" {
  description = "Contact name for taggin resources"
  default     = "me@example.com"
}

variable "tf_state_bucket" {
  description = "Name of s3 bucket in AWS for storing TF state"
  default     = "devops-tf-state-bookyland"
}

variable "tf_state_lock_table" {
  description = "Name of Dynamo table for storing TF lock"
  default     = "devops-tf-lock-bookyland"
}

variable "prefix" {
  description = "Prefix for resources in AWS"
  default     = "bookyland"
}

// RDS
variable "db_password" {
  description = "Passowrd for the Terraform databse"
}

variable "db_username" {
  description = "Database Username"
  default     = "bookyland_user"
}

// ECR
variable "ecr_app_image" {
  description = "Path to the ECR repo with the API image"
}
