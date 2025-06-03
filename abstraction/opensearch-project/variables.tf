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

# Interactive input variables
variable "app_name" {
  description = "Enter the application name"
  type        = string
}

variable "role_name" {
  description = "Enter the role name"
  type        = string
}

variable "create_user" {
  description = "Do you want to create a user? (true/false)"
  type        = bool
}

variable "user_password" {
  description = "Enter user password if creating user"
  type        = string
  default     = null
}

variable "create_role" {
  description = "Do you want to create a custom role? (true/false)"
  type        = bool
}

variable "cluster_permissions" {
  description = "List of cluster permissions"
  type        = list(string)
  default     = []
}

variable "index_patterns" {
  description = "List of index patterns"
  type        = list(string)
  default     = []
}

variable "index_actions" {
  description = "List of allowed index actions"
  type        = list(string)
  default     = []
}

variable "tenant_patterns" {
  description = "List of tenant patterns"
  type        = list(string)
  default     = []
}

variable "tenant_actions" {
  description = "List of tenant actions"
  type        = list(string)
  default     = []
}

variable "backend_roles" {
  description = "List of backend roles (IAM ARNs)"
  type        = list(string)
}

variable "existing_role" {
  description = "Name of existing role to use when not creating a new role"
  type        = string
  default     = null
}