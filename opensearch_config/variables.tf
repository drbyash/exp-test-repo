# Provider Variables
variable "opensearch_url" {
  description = "URL of the OpenSearch cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region where the OpenSearch cluster is deployed"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
  default     = "default"
}

variable "insecure" {
  description = "Whether to skip TLS certificate validation"
  type        = bool
  default     = false
}

# Admin Role Variables
variable "admin_role_name" {
  description = "Name of the admin role"
  type        = string
  default     = "mycompany_admin_role"
}

variable "admin_role_description" {
  description = "Description for the admin role"
  type        = string
  default     = "Administrator role with full access"
}

variable "admin_cluster_permissions" {
  description = "Cluster permissions for the admin role"
  type        = list(string)
  default     = ["*"]
}

variable "admin_index_patterns" {
  description = "Index patterns for the admin role"
  type        = list(string)
  default     = ["*"]
}

variable "admin_index_actions" {
  description = "Allowed actions for the admin role on indices"
  type        = list(string)
  default     = ["*"]
}

variable "admin_tenant_patterns" {
  description = "Tenant patterns for the admin role"
  type        = list(string)
  default     = ["*"]
}

variable "admin_tenant_actions" {
  description = "Allowed actions for the admin role on tenants"
  type        = list(string)
  default     = ["*"]
}

# Read-only Role Variables
variable "readonly_role_name" {
  description = "Name of the read-only role"
  type        = string
  default     = "mycompany_readonly_role"
}

variable "readonly_role_description" {
  description = "Description for the read-only role"
  type        = string
  default     = "Read-only role for monitoring and analytics"
}

variable "readonly_cluster_permissions" {
  description = "Cluster permissions for the read-only role"
  type        = list(string)
  default     = ["cluster:monitor/*", "cluster_composite_ops_ro"]
}

variable "readonly_index_patterns" {
  description = "Index patterns for the read-only role"
  type        = list(string)
  default     = ["*"]
}

variable "readonly_index_actions" {
  description = "Allowed actions for the read-only role on indices"
  type        = list(string)
  default     = [
    "indices:admin/get",
    "indices:admin/mappings/get",
    "indices:data/read/*",
    "indices_monitor"
  ]
}

variable "readonly_tenant_patterns" {
  description = "Tenant patterns for the read-only role"
  type        = list(string)
  default     = ["global"]
}

variable "readonly_tenant_actions" {
  description = "Allowed actions for the read-only role on tenants"
  type        = list(string)
  default     = ["kibana_read"]
}

# Role Mapping Variables
variable "admin_mapping_description" {
  description = "Description for the admin role mapping"
  type        = string
  default     = "Maps admin IAM roles to OpenSearch admin role"
}

variable "admin_backend_roles" {
  description = "Backend roles for the admin role mapping"
  type        = list(string)
  default     = ["arn:aws:iam::779846821024:role/mycompany-dev-admin"]
}

variable "readonly_mapping_description" {
  description = "Description for the read-only role mapping"
  type        = string
  default     = "Maps analyst IAM roles to OpenSearch readonly role"
}

variable "readonly_backend_roles" {
  description = "Backend roles for the read-only role mapping"
  type        = list(string)
  default     = ["arn:aws:iam::779846821024:role/mycompany-dev-analyst"]
}
