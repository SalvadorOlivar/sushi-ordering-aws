resource "aws_db_instance" "sushi_db" {
  identifier              = var.db_name
  allocated_storage       = var.db_allocated_storage
  engine                  = var.db_engine
  engine_version          = "8.0"
  instance_class          = var.db_instance_class
  username                = var.db_username
  password                = var.db_password
  port                    = var.db_port
  publicly_accessible     = false
  skip_final_snapshot     = true
  deletion_protection     = false
  multi_az                = false
  storage_encrypted       = false
  backup_retention_period = 0

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.sushi_subnet.name

  tags = {
    Environment = "Test"
    Project     = "Sushi"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sushi_sg"
  description = "Permite acceso a RDS desde Lambda"
  vpc_id      = var.vpc_id

  ingress {
    from_port                = var.db_port
    to_port                  = var.db_port
    protocol                 = "tcp"
    security_groups          = [var.lambda_sg_id]
    description              = "Permite acceso solo desde Lambda SG"
  }
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_db_subnet_group" "sushi_subnet" {
  name        = "sushi-db-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "Subnets para RDS"
}