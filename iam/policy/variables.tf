variable "tags" {
  type = map(string)
}

variable "create_json" {
  type = bool
  default = false
}

variable "create_policy" {
  type = map(object({
    sid = optional(string, null)
    effect = optional(string, "Allow")
    actions = list(string)
    resources = list(string)

    principal = optional(object({
      type        = string
      identifiers = list(string)
    }))
  }))
}