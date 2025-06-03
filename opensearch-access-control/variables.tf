variable "opensearch_users" {
  description = "Map of OpenSearch users configurations"
  type = map(object({
    password = string
    backend_roles = optional(list(string), [])
    attributes = optional(map(string), {})
  }))
}

variable "opensearch_roles" {
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

variable "role_mappings" {
  description = "Map of role to backend roles mappings"
  type = map(object({
    backend_roles = list(string)
    hosts        = optional(list(string), [])
    users        = optional(list(string), [])
  }))
  default = {}
}

variable "opensearch_username" {
 description = "Username for OpenSearch basic authentication (if applicable)"
 type        = string
 default     = null
}

variable "opensearch_password" {
 description = "Password for OpenSearch basic authentication (if applicable)"
 type        = string
default     = null
 sensitive   = true
}

variable "aws_region" {
  description = "AWS region where the OpenSearch cluster is deployed"
  type        = string
  default     = "us-east-1"
}


variable "insecure" {
  description = "Whether to skip TLS certificate validation"
  type        = bool
  default     = false
}

variable "opensearch_url" {
  description = "URL of the OpenSearch cluster"
  type        = string
}
