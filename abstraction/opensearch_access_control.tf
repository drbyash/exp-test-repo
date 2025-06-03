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


variable "application_config" {
  description = "Configuration for OpenSearch access control"
  type = object({
    name = string
    access_control = map(object({
      create_user    = bool
      password      = optional(string, null)
      create_role   = bool
      permissions   = optional(object({
        cluster_permissions = optional(list(string), [])
        index_permissions  = optional(list(object({
          index_patterns  = list(string)
          allowed_actions = list(string)
        })), [])
        tenant_permissions = optional(list(object({
          tenant_patterns = list(string)
          allowed_actions = list(string)
        })), [])
      }), null)
      existing_role = optional(string, null)
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


