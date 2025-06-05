# modules/opensearch_access_control/outputs.tf
output "users" {
  description = "OpenSearch users"
  value = [for user in opensearch_user.users : user.username]
}

output "roles" {
  description = "OpenSearch roles"
  value = [for role in opensearch_role.roles : role.role_name]
}

