output "role_mapping_names" {
  value = keys(opensearch_role_mapping.mappings)
}

