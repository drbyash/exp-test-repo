output "role_mapping_names" {
  value = keys(opensearch_roles_mapping.mapper)
}

