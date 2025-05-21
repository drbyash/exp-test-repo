# Provider Configuration
opensearch_url = "https://vpc-mycompany-dev-opensearch-ti5oqto3qpimtyymrgyrgwsouy.ap-south-1.es.amazonaws.com"
aws_region     = "ap-south-1"
insecure       = false

# Admin Role Values
admin_role_name           = "mycompany_admin_role"
admin_role_description    = "Administrator role with full access"
admin_cluster_permissions = ["*"]
admin_index_patterns      = ["*"]
admin_index_actions       = ["*"]
admin_tenant_patterns     = ["*"]
admin_tenant_actions      = ["*"]
#opensearch_username = "admin"
#opensearch_password = "Admin@123"


#master user ARN
master_user_arn = "arn:aws:iam::779846821024:role/pr1c-installer-RolesSSMDefaultRoleForOneClickPvreRe-Zeuc8gN14spm"


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

# Cadie Role Values
cadie_role_name           = "cadie_role"
cadie_role_description    = "Cadie application role for specific operations"
cadie_cluster_permissions = [
  "cluster:monitor/*",
  "cluster_composite_ops_ro"
]
cadie_index_patterns      = ["cadie-*"]
cadie_index_actions       = [
  "indices:admin/mapping/put",
  "indices:data/write/*",
  "indices:data/read/*",
  "indices:admin/create"
]
cadie_tenant_patterns     = ["cadie"]
cadie_tenant_actions      = ["kibana_all_write"]
cadie_mapping_description = "Maps cadie IAM role to OpenSearch cadie role"
cadie_backend_roles       = ["arn:aws:iam::779846821024:role/cadie-role"]
