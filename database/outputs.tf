output "security_group" {
  value = aws_security_group.db_sg.id
}

output "rds_endpoint" {
  value = aws_db_instance.db.endpoint
}

output "db_name" {
  value = aws_db_instance.db.db_name
}

output "db_secret_arn" {
  value = aws_db_instance.db.master_user_secret[0].secret_arn
}