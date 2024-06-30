resource "aws_instance" "dev_bookyland_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags = {
    Name = var.tag_name
  }
  key_name                    = "aws_key"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.sg_enable_ssh_https, var.ec2_sg_name]
  associate_public_ip_address = var.enable_public_ip_address

  user_data = var.user_data_install

  metadata_options {
    http_endpoint = "enabled"  # Enable the IMDSv2 endpoint
    http_tokens   = "required" # Require the use of IMDSv2 tokens
  }
}

resource "aws_key_pair" "dev_bookyland_public_key" {
  key_name   = "aws_key"
  public_key = var.public_key
}