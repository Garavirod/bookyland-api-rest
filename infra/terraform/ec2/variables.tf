variable "ami_id" {
  type        = string
  description = "ami id for the EC2 instance"
}
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}
variable "tag_name" {
  type        = string
  description = "EC2 tag"
}
variable "public_key" {
  type        = string
  description = "EC2 SSH public key for remote connection"
}
variable "subnet_id" {
  type        = string
  description = "value"
}
variable "sg_enable_ssh_https" {
  description = "Security group ssh connection enable"
}

variable "enable_public_ip_address" {
  type        = string
  description = "Public ip EC2 instance address"
}
variable "user_data_install" {
  type        = string
  description = "EC2 instance user data"
}
variable "ec2_sg_name" {
  type        = string
  description = "Name for security group"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR VPC"
}