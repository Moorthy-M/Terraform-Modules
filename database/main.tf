resource "aws_security_group" "db_sg" {
  name   = "SG-DB"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules

    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
      description     = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules

    content {
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidr_blocks
      security_groups = egress.value.security_groups
      description     = egress.value.description
    }
  }

  tags = merge(var.tags, {
    Name = "${var.db_name}-SG"
  })
}

resource "aws_db_subnet_group" "db_subnet_group" {
  subnet_ids = var.db_subnets

  tags = merge(var.tags, {
    Name = "${var.db_name}-DB-Subnet-Group"
  })
}

resource "aws_db_instance" "db" {
  identifier     = lower("${var.db_identifier}-db")
  instance_class = var.db_instance_class

  engine         = var.db_engine
  engine_version = var.db_engine_version

  allocated_storage = var.db_allocated_storage
  storage_type      = var.db_storage_type
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_user_name
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false

  multi_az                   = var.db_multi_az
  auto_minor_version_upgrade = true
  deletion_protection        = var.db_deletion_protection

  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = var.db_skip_final_snapshot

  tags = merge(var.tags, {
    Name = "${var.db_identifier}"
    Database = "${var.db_name}-database"
  })
}
