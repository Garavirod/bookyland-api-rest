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
variable "public_key_name" {
  type        = string
  description = "EC2 SSH public key name for remote connection"
}
variable "sg_enable_ssh_https_id" {
  description = "Security group ssh connection enable"
}

variable "sg_enable_public_ip_address_id" {
  type        = string
  description = "Public ip EC2 instance address"
}

variable "enable_public_ip_address" {
  type = bool
}
variable "user_data_script_install" {
  type        = string
  description = "EC2 instance user data"
}
variable "ec2_api_backend_security_group_id" {
  type        = string
  description = "CIDR VPC"
}

output "ssh_connection_string_for_ec2" {
  value = format("%s%s", "ssh -i /home/ubuntu/keys/aws_ec2_terraform ubuntu@", aws_instance.dev_bookyland_ec2.public_ip)
}

output "dev_bookyland_ec2_instance_id" {
  value = aws_instance.dev_bookyland_ec2.id
}

resource "aws_instance" "dev_bookyland_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags = {
    Name = var.tag_name
  }
  key_name                    = var.public_key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.sg_enable_ssh_https_id, var.ec2_api_backend_security_group_id]
  associate_public_ip_address = var.enable_public_ip_address

  user_data = var.user_data_script_install

  metadata_options {
    http_endpoint = "enabled"  # Enable the IMDSv2 endpoint
    http_tokens   = "required" # Require the use of IMDSv2 tokens
  }
}

resource "aws_key_pair" "dev_bookyland_public_key" {
  key_name   = var.public_key_name
  public_key = var.public_key
}