variable "tags" {
    type = map(string)
}

variable "vpc_cidr" {
  type = string
  default = "10.10.0.0/16"
  description = "Main Virtual Private Cloud"
}

variable "public_subnets" {
  type = map(object({
    cidr_block = string
    availability_zone = string
    nat = optional(bool, false)
  }))

  validation {
    condition = alltrue([for az in distinct([for obj in var.public_subnets : obj.availability_zone]) : 
    length([ for id,obj in var.public_subnets : id if obj.availability_zone == az && obj.nat]) <=1 ])
    error_message = "Each Availability Zone may have at most one NAT-enabled public subnet."
  }
}

variable "private_subnets" {
  type = map(object({
    cidr_block = string
    availability_zone = string
    tier = string
  }))

  validation {
    condition = alltrue([ for obj in var.private_subnets : contains(["app","db"], lower(obj.tier)) ])
    error_message = "Tier should be either app or db"
  }
}

variable "enable_nat" {
  type = bool
  default = false
  description = "NAT"
}

variable "enable_vpc_flow_logs" {
  type = bool
  default = true
  description = "VPC Flow Logs"
}

variable "vpc_flowlogs_role_arn" {
  type = string
  default = null
  description = "VPC Flow Logs Assume Role ARN"

  validation {
    condition = ( !var.enable_vpc_flow_logs || var.flow_logs_bucket || (var.vpc_flowlogs_role_arn != null && length(var.vpc_flowlogs_role_arn) > 0))
    error_message = "vpc_flowlogs_role_arn must be set when VPC Flow Logs are enabled and CloudWatch Logs is used."
  }
}

variable "flow_logs_destination" {
  type = string
}

variable "flow_logs_bucket" {
  type = bool
  default = false
}


