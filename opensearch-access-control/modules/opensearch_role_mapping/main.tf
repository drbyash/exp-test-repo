resource "opensearch_role_mapping" "mapper" {
  for_each = var.role_mappings

  role_name     = each.key
  backend_roles = each.value.backend_roles
  hosts         = each.value.hosts
  users         = each.value.users
}
