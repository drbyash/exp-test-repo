resource "opensearch_user" "users" {
  for_each = var.users

  username      = each.key
  password      = each.value.password
  backend_roles = each.value.backend_roles
  attributes    = each.value.attributes
}