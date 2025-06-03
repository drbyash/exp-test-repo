# modules/opensearch_access_control/variables.tf
variable "application_config" {
  description = "Application configuration for OpenSearch access control"
  type = object({
    name = string
    access_control = map(object({
      create_user    = bool
      password      = optional(string)
      create_role   = bool
      permissions   = optional(object({
        cluster_permissions = list(string)
        index_permissions  = list(object({
          index_patterns  = list(string)
          allowed_actions = list(string)
        }))
        tenant_permissions = optional(list(object({
          tenant_patterns = list(string)
          allowed_actions = list(string)
        })))
      }))
      existing_role = optional(string)
      backend_roles = list(string)
    }))
  })

  validation {
    condition = alltrue([
      for k, v in var.application_config.access_control :
      (!v.create_role && v.existing_role != null) || (v.create_role && v.permissions != null)
    ])
    error_message = "When create_role is false, existing_role must be provided. When create_role is true, permissions must be provided."
  }

  validation {
    condition = alltrue([
      for k, v in var.application_config.access_control :
      !v.create_user || (v.create_user && v.password != null)
    ])
    error_message = "Password must be provided when create_user is true."
  }
}
