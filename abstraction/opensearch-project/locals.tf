# locals.tf
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
        existing_role = var.create_role ? null : var.existing_role
        backend_roles = var.backend_roles
      }
    }
  }
}