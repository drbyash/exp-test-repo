# terraform.tfvars
opensearch_endpoint = "https://your-opensearch-domain.region.es.amazonaws.com"
aws_region         = "us-west-2"

application_config = {
  name = "cadie"
  access_control = {
    "admin" = {
      create_user  = true
      password    = "StrongPassword123!"
      create_role = true
      permissions = {
        cluster_permissions = ["cluster:monitor/*"]
        index_permissions = [
          {
            index_patterns  = ["cadie-*"]
            allowed_actions = ["indices:*"]
          }
        ]
        tenant_permissions = [
          {
            tenant_patterns = ["cadie_*"]
            allowed_actions = ["kibana_all_write"]
          }
        ]
      }
      backend_roles = ["arn:aws:iam::123456789012:role/CadieAdminRole"]
    }
  }
}
