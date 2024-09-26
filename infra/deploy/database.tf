#######
# RDS #
#######

/* Subnet group */
resource "aws_db_subnet_group" "main" {
  name = "${local.prefix}-main"
  /* Rds are able to run in multiple subnets by using
    subnet groups, private subnets in this case */
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "${local.prefix}-db-subnet-group"
  }
}

/* Security group */
resource "aws_security_group" "rds" {
  description = "Allow access to RDS instance"
  name        = "${local.prefix}-rds-inboud-access"
  vpc_id      = aws_vpc.main.id
  // Rules
  ingress {
    protocol  = "tcp"
    from_port = 3306
    to_port   = 3306
    security_groups = [
      aws_security_group.ecs_service.id
    ]
  }
  tags = {
    Name = "${local.prefix}-db-security-group"
  }
}

/* RDS Mysql */
resource "aws_db_instance" "main" {
  identifier                 = "${local.prefix}-db"
  db_name                    = "bookyland"
  allocated_storage          = 20    // GB
  storage_type               = "gp2" // General propouse
  engine                     = "mysql"
  engine_version             = "8.0.35"
  auto_minor_version_upgrade = true // ensure security fixes are automatically applied, no downtime
  instance_class             = "db.t4g.micro"
  username                   = var.db_username
  password                   = var.db_password
  skip_final_snapshot        = true
  db_subnet_group_name       = aws_db_subnet_group.main.name
  multi_az                   = false
  backup_retention_period    = 0
  vpc_security_group_ids     = [aws_security_group.rds.id]
  tags = {
    Name = "${local.prefix}-main"
  }
}

