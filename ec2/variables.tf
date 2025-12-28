variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}

variable "ingress_rules" {
  type = list(object(
    {
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])
      security_groups = optional(list(string), [])
      description     = optional(string, "")
    }
  ))

  validation {
    condition     = alltrue([for i in var.ingress_rules : i.from_port <= i.to_port])
    error_message = "from_port must be <= to_port"
  }
}

variable "egress_rules" {
  type = list(object(
    {
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string), [])
      security_groups = optional(list(string), [])
      description     = optional(string, "")
    }
  ))

  validation {
    condition     = alltrue([for i in var.egress_rules : i.from_port <= i.to_port])
    error_message = "from_port must be <= to_port"
  }
}

variable "ami_name" {
  type = string
}

variable "ami_image_id" {
  type = string
}

variable "ami_instance_type" {
  type = string
}

variable "ec2_key_name" {
  type = string
}

variable "asg_name" {
  type = string
}

variable "asg_min_size" {
  type = string
}

variable "asg_max_size" {
  type = string
}

variable "asg_desired_capacity" {
  type = string
}

variable "asg_vpc_zones" {
  type = list(string)
}

variable "asg_target_group_arn" {
  type = string
}

variable "user_data" {
  type = string
}

variable "root_device_name" {
  type = string
}