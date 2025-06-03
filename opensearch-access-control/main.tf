module "opensearch_users" {
  source = "./opensearch-access-control/modules/opensearch_user"
  users  = var.opensearch_users
}

module "opensearch_roles" {
  source = "./opensearch-access-control/modules/opensearch_role"
  roles  = var.opensearch_roles
}

module "opensearch_role_mappings" {
  source        = "./opensearch-access-control/modules/opensearch_role_mapping"
  role_mappings = var.role_mappings
}

