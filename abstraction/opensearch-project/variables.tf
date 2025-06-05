# variables.tf
variable "opensearch_endpoint" {
  description = "OpenSearch endpoint URL"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "opensearch_username" {
  description = "OpenSearch username"
  type        = string
  default     = null
}

variable "opensearch_password" {
  description = "OpenSearch password"
  type        = string
  default     = null
  sensitive   = true
}

variable "insecure" {
  description = "Skip TLS verification"
  type        = bool
  default     = false
}

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
      existing_roles = list(string)
      backend_roles = list(string)
      custom_attributes= map(string)
    }))
  })
}
