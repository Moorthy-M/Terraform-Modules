locals {
  is_fargate = upper(var.service_launch_type) == "FARGATE"
}

resource "aws_security_group" "service" {
  name   = "${var.service_name}-service-sg"
  vpc_id = var.network.vpc

  ingress {
    from_port       = var.container.port
    to_port         = var.container.port
    protocol        = "tcp"
    security_groups = var.network.security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags,
    {
      Name = "SG-${var.service_name}-service"
  })
}

resource "aws_lb_target_group" "target" {
  name = "${var.service_name}-target-group"
  vpc_id = var.network.vpc

  port = var.container.port
  protocol = var.alb.protocol
  target_type = local.is_fargate ? "ip" : "instance"

  health_check {
    path = var.alb.health_path
    protocol = var.alb.protocol
    matcher = "200-399"
    interval = 30
    timeout = 10
    healthy_threshold = 3
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.service_name}-target-group"
  })
}

resource "aws_lb_listener_rule" "listener" {
  listener_arn = var.alb.listener_arn

  priority = var.alb.priority

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target.arn
  }

  condition {
    path_pattern {
      values = [ var.alb.route_path ]
    }
  }
  tags = merge(var.tags, {
    Name = "${var.service_name}-${aws_lb_target_group.target.name}-listener_rule"
  })
}

resource "aws_ecs_task_definition" "task_definition" {
    family = var.task_definition_family
    requires_compatibilities = local.is_fargate ? ["FARGATE"] : ["EC2"]
    network_mode = local.is_fargate ? "awsvpc" : "bridge"
    cpu = var.task_definition_cpu
    memory = var.task_definition_memory

    execution_role_arn = var.execution_role_arn
    task_role_arn = var.task_role_arn

    container_definitions = jsonencode([
    {
      name  = var.container.name
      image = var.container.image
      essential = true
      
      portMappings = [
        {
          containerPort = var.container.port
          protocol      = "tcp"
        }
      ]
    }
  ])

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
  deployment_circuit_breaker {
    enable =  true
    rollback = true
  }

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
      subnets = var.network.subnets
    security_groups = [aws_security_group.service.id]
    assign_public_ip = false
    }
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target.arn
    container_name = var.container.name
    container_port = var.container.port
  }

  lifecycle {
    ignore_changes = [ task_definition ]
  }
  
  propagate_tags = "SERVICE"

  tags = merge(var.tags, {
    Name = "${var.service_name}-service"
  })
}

