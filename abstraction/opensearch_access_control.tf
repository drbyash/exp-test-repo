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
  url         = var.opensearch_url
  username    = var.opensearch_username
  password    = var.opensearch_password
  aws_region  = var.aws_region
  insecure    = var.insecure
}


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

variable "opensearch_url" {
  description = "URL of the OpenSearch cluster"
  type        = string
}

variable "access_control" {
  description = "Access control configuration for OpenSearch"
  type = object({
    name = string
    access_control = map(object({
      create_user    = bool
      password       = optional(string)
      create_role    = bool
      permissions    = optional(object({
        cluster_permissions = optional(list(string), [])
        index_permissions = optional(list(object({
          index_patterns  = list(string)
          allowed_actions = list(string)
        })), [])
        tenant_permissions = optional(list(object({
          tenant_patterns = list(string)
          allowed_actions = list(string)
        })), [])
      }))
      existing_role = optional(string)
      backend_roles = optional(list(string), [])
    }))
  })
}

locals {
  app_name = var.access_control.name
  
  # Process users
  users = {
    for role_name, config in var.access_control.access_control :
    "${local.app_name}_${role_name}_user" => {
      password      = config.password
      backend_roles = []
      attributes    = {}
    }
    if config.create_user == true && config.password != null
  }
  
  # Process roles
  roles = {
    for role_name, config in var.access_control.access_control :
    "${local.app_name}_${role_name}" => {
      cluster_permissions = try(config.permissions.cluster_permissions, [])
      index_permissions   = try(config.permissions.index_permissions, [])
      tenant_permissions  = try(config.permissions.tenant_permissions, [])
    }
    if config.create_role == true && config.permissions != null
  }
  
  # Process role mappings
  role_mappings = merge(
    # Role mappings for created roles
    {
      for role_name, config in var.access_control.access_control :
      "${local.app_name}_${role_name}" => {
        backend_roles = concat(
          config.backend_roles,
          config.create_user ? ["${local.app_name}_${role_name}_user"] : []
        )
      }
      if config.create_role == true && (length(config.backend_roles) > 0 || config.create_user)
    },
    # Role mappings for existing roles
    {
      for role_name, config in var.access_control.access_control :
      config.existing_role => {
        backend_roles = concat(
          config.backend_roles,
          config.create_user ? ["${local.app_name}_${role_name}_user"] : []
        )
      }
      if config.create_role == false && config.existing_role != null && (length(config.backend_roles) > 0 || config.create_user)
    }
  )
}



# OpenSearch User Resource
resource "opensearch_user" "users" {
  for_each = local.users

  username      = each.key
  password      = each.value.password
  backend_roles = each.value.backend_roles
  attributes    = each.value.attributes
}

# OpenSearch Role Resource
resource "opensearch_role" "roles" {
  for_each = local.roles

  role_name = each.key
  
  cluster_permissions = each.value.cluster_permissions

  dynamic "index_permissions" {
    for_each = each.value.index_permissions
    content {
      index_patterns   = index_permissions.value.index_patterns
      allowed_actions  = index_permissions.value.allowed_actions
    }
  }

  dynamic "tenant_permissions" {
    for_each = each.value.tenant_permissions
    content {
      tenant_patterns  = tenant_permissions.value.tenant_patterns
      allowed_actions  = tenant_permissions.value.allowed_actions
    }
  }
}

# OpenSearch Role Mapping Resource
resource "opensearch_roles_mapping" "mappings" {
  for_each = local.role_mappings

  role_name     = each.key
  backend_roles = each.value.backend_roles
  
  depends_on = [
    opensearch_user.users,
    opensearch_role.roles
  ]
}

output "created_users" {
  value = keys(opensearch_user.users)
}

output "created_roles" {
  value = keys(opensearch_role.roles)
}

output "created_role_mappings" {
  value = keys(opensearch_roles_mapping.mappings)
}
