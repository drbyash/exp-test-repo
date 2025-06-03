variable "roles" {
  description = "Map of OpenSearch roles configurations"
  type = map(object({
    cluster_permissions = optional(list(string), [])
    index_permissions = optional(list(object({
      index_patterns = list(string)
      allowed_actions = list(string)
      masked_fields = optional(list(string), [])
      field_level_security = optional(map(list(string)), {})
    })), [])
    tenant_permissions = optional(list(object({
      tenant_patterns = list(string)
      allowed_actions = list(string)
    })), [])
  }))
}