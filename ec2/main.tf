resource "aws_security_group" "security_group" {
  name   = "SG-EC2"
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
      Name = "SG-EC2"
  })
}

resource "aws_launch_template" "launch_template" {
  name_prefix            = var.ami_name
  image_id               = var.ami_image_id
  instance_type          = var.ami_instance_type
  vpc_security_group_ids = [aws_security_group.security_group.id]
  user_data              = base64encode(var.user_data)

  key_name = var.ec2_key_name
  
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  block_device_mappings {
    device_name = var.root_device_name

    ebs {
      encrypted             = true
      delete_on_termination = true
      volume_size = 10
      volume_type           = "gp3"
    }
  }

  monitoring {
    enabled = true
  }
  
  tags = merge(var.tags,
    {
      Name = "Launch-Template-EC2"
  })

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "EC2-Web"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "EC2-Web-Volume"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = var.asg_name
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  vpc_zone_identifier = var.asg_vpc_zones

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300
  target_group_arns         = [var.asg_target_group_arn]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Environment"
    value               = lookup(var.tags, "Environment", "Production")
    propagate_at_launch = true
  }
}