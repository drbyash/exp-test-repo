resource "opensearch_role" "roles" {
  for_each = var.roles

  role_name = each.key
  
  cluster_permissions = each.value.cluster_permissions

  dynamic "index_permissions" {
    for_each = each.value.index_permissions
    content {
      index_patterns       = index_permissions.value.index_patterns
      allowed_actions     = index_permissions.value.allowed_actions
      masked_fields      = index_permissions.value.masked_fields
      field_level_security = index_permissions.value.field_level_security
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