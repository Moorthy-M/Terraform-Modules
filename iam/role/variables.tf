variable "tags" {
  type = map(string)
}

variable "create_role" {
  type = map(object({
    trust = object({
      type = string
      identifiers = list(string)
    })
    
    managed_policy = optional(list(string), [])
    permission_policy = optional(list(string), [])
  }))

  validation {
    condition = alltrue([ for i in var.create_role : contains(["Service","AWS","Federated","CanonicalUser"], i.trust.type) ])
    error_message = "Type must be one of: Service, AWS, Federated and CanonicalUser"
  }
}