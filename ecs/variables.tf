//Tags
variable "tags" {
    type = map(string)
}

// Cluster
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

variable "container_definitions" {
    type = list(any)
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

variable "service_target_group_arn" {
    type = string
}

variable "service_container_name" {
    type = string
  default = "app"
}

variable "service_container_port" {
    type = number
  default = 80
}

variable "service_subnets" {
  type = list(string)
}

variable "service_security_groups" {
  type = list(string)
}

