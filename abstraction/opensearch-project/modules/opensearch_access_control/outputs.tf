# modules/opensearch_access_control/outputs.tf
output "users" {
  description = "Created OpenSearch users"
  value = [for user in opensearch_user.users : user.username]
}

output "roles" {
  description = "Created OpenSearch roles"
  value = [for role in opensearch_role.roles : role.role_name]
}

output "role_mappings" {
  description = "Created OpenSearch role mappings"
  value = [for mapping in opensearch_roles_mapping.mappings : mapping.role_name]
}