//Tags
variable "tags" {
    type = map(string)
}

// Cluster
variable "cluster_name" {
    type = string
}

variable "cluster_id" {
    type = string
}

//Task Definition
variable "task_definition_family" {
    type = string
  default = "default-family"
}

variable "task_definition_cpu" {
    type = string
  default = "256"
}

variable "task_definition_memory" {
    type = string
  default = "512"
}

variable "execution_role_arn" {
    type = string
}

variable "task_role_arn" {
    type = string
}

variable "network" {
    type = object({
      vpc  = string
      subnets  = list(string)
      security_groups = list(string)
    })
}

variable "alb" {
    type = object({
      listener_arn  = string
      priority = number
      health_path = string
      route_path = string
      protocol  = string
    })
}

variable "container" {
    type = object({
      name  = string
      port  = number
      image = string
      secrets = optional(bool, false)
    })
}

variable "db_secrets_arn" {
    type = string
    default = ""
}

variable "db_environments" {
    type = object({
      host = string
      port = number
      name = string
    })

    default = {
      host = ""
      port = -1
      name = ""
    }
}

variable "health_check_path" {
    type = string
    default = "/"
}

//Service
variable "service_name" {
    type = string
  default = "default-service"
}

variable "service_launch_type" {
  type    = string
  default = "FARGATE"
  validation {
    condition     = contains(["FARGATE", "EC2"], upper(var.service_launch_type))
    error_message = "Must be FARGATE or EC2."
  }
}

/* variable "capacity_provider_strategy" {
  type = map(object({
    capacity_provider = string
    weight = number
  }))

  default = {
    "fargate" = {
      capacity_provider = "FARGATE"
      weight = 1 //100%
    }
  }
} */

variable "service_desired_count" {
    type = number
  default = 2
}

