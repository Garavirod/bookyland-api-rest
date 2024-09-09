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

data "aws_caller_identity" "current" {}

// Github
variable "github_user_name" {
  description = "Github Username"
  default     = "Garavirod"
}

variable "github_url_repo" {
  description = "Github repository project url"
  default     = "https://github.com/Garavirod/bookyland-api-rest"
}

variable "github_repository_name" {
  description = "Github repository project"
  default     = "bookyland-api-rest"
}

