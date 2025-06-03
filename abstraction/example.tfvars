opensearch_url = "https://your-opensearch-endpoint.region.es.amazonaws.com"
opensearch_username = "admin"
opensearch_password = "your-password"
aws_region = "us-east-1"

access_control = {
  name = "app"
  access_control = {
    "analyst" = {
      create_user = true
      password = "SecurePassword123!"
      create_role = true
      permissions = {
        cluster_permissions = ["cluster_composite_ops_ro"]
        index_permissions = [
          {
            index_patterns = ["data-*"]
            allowed_actions = ["read", "search"]
          }
        ]
        tenant_permissions = [
          {
            tenant_patterns = ["analytics"]
            allowed_actions = ["kibana_all_read"]
          }
        ]
      }
      backend_roles = ["arn:aws:iam::123456789012:role/AnalystRole"]
    }
  }
}
