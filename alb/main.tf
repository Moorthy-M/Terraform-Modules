resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
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

  tags = merge(var.tags,
    {
      Name = "SG-${var.alb_name}"
    }
  )
}

resource "aws_lb" "alb" {
  name               = var.alb_name
  internal           = var.alb_internal
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = [aws_security_group.alb_sg.id]

  enable_deletion_protection = var.enable_deletion_protection

  access_logs {
    bucket = var.log_bucket
    prefix = "alb"
    enabled = true
  }

  tags = merge(var.tags,
    {
      Name = "ALB-${var.alb_name}"
  })
}

resource "aws_lb_target_group" "alb_tg" {
  vpc_id = var.vpc_id

  port        = var.target_port
  protocol    = var.target_protocol
  target_type = var.target_type

  health_check {
    path                = var.health_check_path
    protocol            = var.health_check_protocol
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    unhealthy_threshold = 2
    healthy_threshold   = 3
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags,
    {
      Name = "TG-${var.alb_name}"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }

  tags = merge(var.tags,
    {
      Name = "Listener-HTTP-${var.alb_name}"
  })
}
