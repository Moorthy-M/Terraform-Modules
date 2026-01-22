output "task_definition_arn" {
  value = aws_ecs_task_definition.task_definition.arn
}

output "service_name" {
  value = aws_ecs_service.service.name
}

output "service_arn" {
  value = aws_ecs_service.service.arn
}