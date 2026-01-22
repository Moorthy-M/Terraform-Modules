output "policies" {
  value = { for name,policy in aws_iam_policy.policy : name => policy.arn }
}

output "policy_json" {
  value = { for name,policy in data.aws_iam_policy_document.policy : name => policy.json }
  sensitive = true
}