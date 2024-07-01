variable "ec2_security_group_name" {}
variable "vpc_id" {}
variable "public_subnet_cicr_blcok" {}
variable "security_group_name_for_app" {}
output "ec2_ssh_http_security_group_id" {
  value = aws_security_group.ec2_ssh_http_security_group.id
}
output "rds_mysql_security_group_id" {
  value = aws_security_group.rds_mysql_security_group.id
}
output "ec2_api_backend_security_group_id" {
  value = aws_security_group.ec2_api_backend_security_group.id
}


// EC2 Security group
resource "aws_security_group" "ec2_ssh_http_security_group" {
  name = var.ec2_security_group_name
  description = "Enamble port 22(SSH) and port 80(http)"
  vpc_id = var.vpc_id

    // ssh for terrafrrom remote exec
  ingress {
    description = "Allow ssh connection from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

    // enamble http connections
  ingress {
    description = "Allow http connections from anywahre"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 443 //  standard port used for HTTPS (Hypertext Transfer Protocol Secure) communication
    to_port = 443
    protocol = "tcp"

  }

  egress {
    description = "Allow outbound all the traffic from anywere"
    from_port = 0 //  A value of 0 for from_port and to_port means any port number on the instance can initiate a connection.
    to_port = 0
    protocol = "-1" //  represents any protocol, including TCP, UDP, ICMP, etc.
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "Security group that allow ssh(22) and http(443) connection"
  }
}

// RDS Security group

resource "aws_security_group" "rds_mysql_security_group" {
    name = "rds-mysql-sg"
    description = "RDS mysql security group"
    vpc_id = var.vpc_id

    ingress {
        from_port = 33066
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = var.public_subnet_cicr_blcok // EC2 instance security group CICR block
    }
}


resource "aws_security_group" "ec2_api_backend_security_group" {
  name = "api-backend-security-group"
  description = "Security group for api bakcned app"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow traffinc on port 8000"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
  }

  tags = {
    Name = "Security group to allow traffic on port 8000"
  }
}