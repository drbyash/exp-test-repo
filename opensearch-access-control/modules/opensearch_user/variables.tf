variable "users" {
  description = "Map of OpenSearch users configurations"
  type = map(object({
    password = string
    backend_roles = optional(list(string), [])
    attributes = optional(map(string), {})
  }))
}