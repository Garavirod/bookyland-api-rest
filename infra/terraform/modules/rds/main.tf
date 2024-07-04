

################
# SUBNET GROUP #
################
resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = var.subnet_ids
}

#######
# RDS #
#######
resource "aws_db_instance" "main" {
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t3.micro"
  username                = var.db_username
  password                = var.db_password
  db_name                 = var.db_name
  db_subnet_group_name    = aws_db_subnet_group.main.id
  skip_final_snapshot     = true
  apply_immediately       = true
  backup_retention_period = 0
  deletion_protection     = false

  vpc_security_group_ids = [aws_security_group.rds.id]
}


##################
# SECURITY GROUP #
##################
resource "aws_security_group" "rds" {
  vpc_id = var.vpc_id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0 // any port
    to_port     = 0
    protocol    = "-1" // any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }
}