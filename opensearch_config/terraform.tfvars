# Provider Configuration
opensearch_url = "https://your-opensearch-endpoint.region.es.amazonaws.com"
aws_region     = "us-east-1"
aws_profile    = "default"
insecure       = false

# Admin Role Values
admin_role_name           = "mycompany_admin_role"
admin_role_description    = "Administrator role with full access"
admin_cluster_permissions = ["*"]
admin_index_patterns      = ["*"]
admin_index_actions       = ["*"]
admin_tenant_patterns     = ["*"]
admin_tenant_actions      = ["*"]

# Read-only Role Values
readonly_role_name           = "mycompany_readonly_role"
readonly_role_description    = "Read-only role for monitoring and analytics"
readonly_cluster_permissions = [
  "cluster:monitor/*",
  "cluster_composite_ops_ro"
]
readonly_index_patterns  = ["*"]
readonly_index_actions   = [
  "indices:admin/get",
  "indices:admin/mappings/get",
  "indices:data/read/*",
  "indices_monitor"
]
readonly_tenant_patterns = ["global"]
readonly_tenant_actions  = ["kibana_read"]

# Role Mapping Values
admin_mapping_description = "Maps admin IAM roles to OpenSearch admin role"
admin_backend_roles       = ["arn:aws:iam::779846821024:role/mycompany-dev-admin"]

readonly_mapping_description = "Maps analyst IAM roles to OpenSearch readonly role"
readonly_backend_roles       = ["arn:aws:iam::779846821024:role/mycompany-dev-analyst"]
