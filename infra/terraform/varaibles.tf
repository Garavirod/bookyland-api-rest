#######
# EC2 #
#######
variable "ami_id" {
  type        = string
  description = "ami id for the EC2 instance"
}
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}
variable "public_key" {
  type        = string
  description = "EC2 SSH public key for remote connection"
}
#######
# vpc #
#######
variable "vpc_name" {
  type = string
  description = "VPC name"
}
variable "vpc_cidr" {
  type        = string
  description = "CIDR VPC"
}
variable "cidr_public_subnet" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "cidr_private_subnet" {
  type        = list(string)
  description = "Private Subnet CIDR values"
}

variable "us_availability_zone" {
  type = list(string)
  description = "Array list of VPC availability zones"
}