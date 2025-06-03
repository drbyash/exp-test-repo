provider "opensearch" {
  url = var.opensearch_endpoint
}

module "opensearch_users" {
  source = "./modules/opensearch_user"
  users  = var.opensearch_users
}

module "opensearch_roles" {
  source = "./modules/opensearch_role"
  roles  = var.opensearch_roles
}

module "opensearch_role_mappings" {
  source        = "./modules/opensearch_role_mapping"
  role_mappings = var.role_mappings
}

