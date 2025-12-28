variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
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

variable "alb_name" {
  type = string
}

variable "alb_internal" {
  type    = bool
  default = false
}

variable "enable_deletion_protection" {
  type    = bool
  default = true
}

variable "target_port" {
  type = number
}

variable "target_protocol" {
  type = string
}

variable "target_type" {
  type = string
}

variable "health_check_path" {
  type = string
}

variable "health_check_protocol" {
  type = string
}

variable "health_check_matcher" {
  type = string
}

variable "health_check_interval" {
  type = number
}

variable "health_check_timeout" {
  type = number
}

