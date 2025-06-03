output "role_names" {
  value = keys(opensearch_role.roles)
}