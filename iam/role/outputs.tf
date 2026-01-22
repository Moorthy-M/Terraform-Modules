output "role_name_arns" {
  value = { for name, role in aws_iam_role.role : name => role.arn }
}

