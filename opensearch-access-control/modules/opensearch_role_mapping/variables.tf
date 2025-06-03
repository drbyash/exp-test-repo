variable "role_mappings" {
  description = "Map of role to backend roles mappings"
  type = map(object({
    backend_roles = list(string)
    hosts        = optional(list(string), [])
    users        = optional(list(string), [])
  }))
}