# terraform.tfvars
opensearch_endpoint = "https://vpc-mycompany-dev-opensearch-ti5oqto3qpimtyymrgyrgwsouy.ap-south-1.es.amazonaws.com"
aws_region     = "ap-south-1"
insecure       = false
opensearch_username = "admin"
opensearch_password = "Admin@123"

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
      backend_roles = ["arn:aws:iam::779846821024:role/access-tester-1"]
    }
  }
}
