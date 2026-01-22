locals {
  is_fargate = upper(var.service_launch_type) == "FARGATE"
}

resource "aws_ecs_task_definition" "task_definition" {
    family = var.task_definition_family
    requires_compatibilities = local.is_fargate ? ["FARGATE"] : ["EC2"]
    network_mode = local.is_fargate ? "awsvpc" : "bridge"
    cpu = var.task_definition_cpu
    memory = var.task_definition_memory

    execution_role_arn = var.execution_role_arn
    task_role_arn = var.task_role_arn

    container_definitions = jsonencode(var.container_definitions)

    tags = merge(var.tags, {
    Name = "${var.task_definition_family}-family"
  }) 
}

resource "aws_ecs_service" "service" {
  name = var.service_name
  cluster = var.cluster_id
  task_definition = aws_ecs_task_definition.task_definition.arn

  desired_count = var.service_desired_count
  launch_type = upper(var.service_launch_type)

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  /* dynamic capacity_provider_strategy {
    for_each = var.capacity_provider_strategy

    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight = capacity_provider_strategy.value.weight
    }
  } */  

  dynamic network_configuration {
    for_each = local.is_fargate ? [1] : []

    content {
      subnets = var.service_subnets
    security_groups = var.service_security_groups
    assign_public_ip = false
    }
  }

  load_balancer {
    target_group_arn = var.service_target_group_arn
    container_name = var.service_container_name
    container_port = var.service_container_port
  }

  propagate_tags = "SERVICE"

  tags = merge(var.tags, {
    Name = "${var.service_name}-service"
  })
}

