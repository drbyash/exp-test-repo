# main.tf

terraform {
  required_version = ">= 0.14.0"
  required_providers {
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = ">= 2.0.0"
    }
  }
}

provider "opensearch" {
    url                   = var.opensearch_endpoint
    aws_region            = var.aws_region
    insecure              = var.insecure
    healthcheck           = false
    username              = var.opensearch_username
    password              = var.opensearch_password 
    sign_aws_requests     = false
}

# Variables
variable "opensearch_endpoint" {
  description = "OpenSearch domain endpoint"
  type        = string
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

variable "user_password" {
  description = "Enter the user password (required if creating user)"
  type        = string
  default     = null

  validation {
    condition     = var.user_password == null || length(var.user_password) >= 8
    error_message = "Password must be at least 8 characters long when provided."
  }
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
# Application Configuration Variables
variable "app_name" {
  description = "Enter the application name"
  type        = string
}

variable "role_name" {
  description = "Enter the role name (e.g., admin, readonly)"
  type        = string
}

variable "create_user" {
  description = "Do you want to create a user? (true/false)"
  type        = bool
}

variable "user_password" {
  description = "Enter the user password (required if creating user)"
  type        = string
  default     = null
}

variable "create_role" {
  description = "Do you want to create a custom role? (true/false)"
  type        = bool
}

variable "cluster_permissions" {
  description = "Enter cluster permissions (e.g., cluster:monitor/*)"
  type        = list(string)
  default     = []
}

variable "index_patterns" {
  description = "Enter index patterns (e.g., app-*)"
  type        = list(string)
  default     = []
}

variable "index_actions" {
  description = "Enter allowed index actions (e.g., indices:*)"
  type        = list(string)
  default     = []
}

variable "tenant_patterns" {
  description = "Enter tenant patterns (optional)"
  type        = list(string)
  default     = []
}

variable "tenant_actions" {
  description = "Enter tenant actions (optional)"
  type        = list(string)
  default     = []
}

variable "backend_roles" {
  description = "Enter backend roles (IAM ARNs)"
  type        = list(string)
}

# Local variable to construct application_config
locals {
  application_config = {
    name = var.app_name
    access_control = {
      "${var.role_name}" = {
        create_user = var.create_user
        password    = var.user_password
        create_role = var.create_role
        permissions = var.create_role ? {
          cluster_permissions = var.cluster_permissions
          index_permissions = [
            {
              index_patterns  = var.index_patterns
              allowed_actions = var.index_actions
            }
          ]
          tenant_permissions = length(var.tenant_patterns) > 0 ? [
            {
              tenant_patterns = var.tenant_patterns
              allowed_actions = var.tenant_actions
            }
          ] : []
        } : null
        backend_roles = var.backend_roles
      }
    }
  }
}

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

# Local variables for transformation
locals {
  # User configurations
  users = {
    for role_name, config in var.application_config.access_control :
    "${var.application_config.name}_${role_name}_user" => {
      password = config.password
      backend_roles = []
      attributes = {
        application = var.application_config.name
        role = role_name
      }
    }
    if config.create_user
  }

  # Role configurations
  roles = {
    for role_name, config in var.application_config.access_control :
    "${var.application_config.name}_${role_name}" => config.permissions
    if config.create_role
  }

  # Role mapping configurations
  role_mappings = merge([
    for role_name, config in var.application_config.access_control : {
      "${config.create_role ? "${var.application_config.name}_${role_name}" : config.existing_role}" = {
        backend_roles = config.backend_roles
        users = config.create_user ? ["${var.application_config.name}_${role_name}_user"] : []
      }
    }
  ]...)
}

# Resources
resource "opensearch_user" "users" {
  for_each = local.users

  username      = each.key
  password      = each.value.password
  backend_roles = each.value.backend_roles
  attributes    = each.value.attributes
}

resource "opensearch_role" "roles" {
  for_each = local.roles

  role_name = each.key
  
  cluster_permissions = each.value.cluster_permissions

  dynamic "index_permissions" {
    for_each = each.value.index_permissions
    content {
      index_patterns       = index_permissions.value.index_patterns
      allowed_actions     = index_permissions.value.allowed_actions
    }
  }

  dynamic "tenant_permissions" {
    for_each = each.value.tenant_permissions
    content {
      tenant_patterns  = tenant_permissions.value.tenant_patterns
      allowed_actions = tenant_permissions.value.allowed_actions
    }
  }
}

resource "opensearch_roles_mapping" "mappings" {
  for_each = local.role_mappings

  role_name     = each.key
  backend_roles = each.value.backend_roles
  users         = each.value.users

  depends_on = [opensearch_role.roles, opensearch_user.users]
}

# Outputs
output "created_users" {
  value = [for user in opensearch_user.users : user.username]
}

output "created_roles" {
  value = [for role in opensearch_role.roles : role.role_name]
}

output "role_mappings" {
  value = [for mapping in opensearch_roles_mapping.mappings : mapping.role_name]
}


