output "task_definition_arn" {
  value = aws_ecs_task_definition.task_definition.arn
}

output "service_name" {
  value = aws_ecs_service.service.name
}

output "service_arn" {
  value = aws_ecs_service.service.arn
}

output "service_sg_id" {
  value = aws_security_group.service.id
}

output "service_tg_id" {
  value = aws_lb_target_group.target.id
}