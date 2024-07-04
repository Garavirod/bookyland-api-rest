variable "load_balancer_arn" {
  type = string
}

variable "vpc_id" {
}

variable "application_name" {
  description = "Application name"
  default     = "bookyland"
  type        = string
}

variable "container_port" {

}