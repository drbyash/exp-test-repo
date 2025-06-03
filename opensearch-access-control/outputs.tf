output "created_users" {
  value = module.opensearch_users.user_names
}

output "created_roles" {
  value = module.opensearch_roles.role_names
}

output "created_role_mappings" {
  value = module.opensearch_role_mappings.role_mapping_names
}