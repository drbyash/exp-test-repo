# Local variables for resource creation
locals {
  # User configurations
  users = { 
    for role_name, config in var.application_config.access_control :
    "${var.application_config.name}_${role_name}_user" => {
      password = config.password
      # backend_roles = config.backend_roles 
      attributes = merge({ #standard attributes
        application = var.application_config.name
        role = role_name
      },
      config.custom_attributes   #user-defined attributes
      )
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
      "${config.create_role ? "${var.application_config.name}_${role_name}" : config.existing_roles}" = {
        backend_roles = config.backend_roles
        users = config.create_user ? ["${var.application_config.name}_${role_name}_user"] : []
      }
    }
  ]...)
}

resource "opensearch_user" "users" {
  for_each = local.users

  username      = each.key
  password      = each.value.password
  # backend_roles = each.value.backend_roles
  attributes    = each.value.attributes
}

resource "opensearch_role" "roles" {
  for_each = local.roles

  role_name = each.key
  
  cluster_permissions = each.value.cluster_permissions

  dynamic "index_permissions" {
    for_each = each.value.index_permissions
    content {
      index_patterns  = index_permissions.value.index_patterns
      allowed_actions = index_permissions.value.allowed_actions
    }
  }

  dynamic "tenant_permissions" {
    for_each = each.value.tenant_permissions != null ? each.value.tenant_permissions : []
    content {
      tenant_patterns = tenant_permissions.value.tenant_patterns
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
