
opensearch_url = "https://vpc-mycompany-dev-opensearch-ti5oqto3qpimtyymrgyrgwsouy.ap-south-1.es.amazonaws.com"
aws_region     = "ap-south-1"
insecure       = false
opensearch_username = "admin"
opensearch_password = "Admin@123"

# Define two users: one for application and one for admin
opensearch_users = {
  "cadie_app_user" = {
    password = "StrongPassword123!" 
    backend_roles = ["cadie_service_role"]
    attributes = {
      application = "cadie"
      environment = "prod"
    }
  },
  "cadie_admin_user" = {
    password = "AdminStrongPassword456!"
    backend_roles = ["cadie_admin_role"]
    attributes = {
      application = "cadie"
      environment = "prod"
      role = "admin"
    }
  }
}

# Define two roles with different permission levels
opensearch_roles = {
  "cadie_read_role" = {
    # Read-only role with limited permissions
    cluster_permissions = [
      "cluster:monitor/*",
      "indices:data/read/*"
    ]
    index_permissions = [
      {
        index_patterns  = ["cadie-*"]
        allowed_actions = [
          "read",
          "search",
          "get"
        ]
        # Mask sensitive fields
        masked_fields = ["user_ssn", "credit_card"]
        field_level_security = {
          include = ["timestamp", "message", "level", "application"]
          exclude = ["internal_id"]
        }
      }
    ]
    tenant_permissions = [
      {
        tenant_patterns = ["cadie_readonly_*"]
        allowed_actions = ["kibana_all_read"]
      }
    ]
  },
  "cadie_admin_role" = {
    # Admin role with extended permissions
    cluster_permissions = [
      "cluster:monitor/*",
      "cluster:admin/opensearch/*"
    ]
    index_permissions = [
      {
        index_patterns  = ["cadie-*"]
        allowed_actions = [
          "indices:*"  # Full index access
        ]
      },
      {
        index_patterns  = ["metrics-*"]
        allowed_actions = [
          "read",
          "search",
          "get"
        ]
      }
    ]
    tenant_permissions = [
      {
        tenant_patterns = ["cadie_*"]
        allowed_actions = ["kibana_all_write"]
      }
    ]
  }
}

# Role mappings including mapping an IAM role to the existing read-only role
role_mappings = {
  "readall" = {
    # Map IAM role to OpenSearch's built-in read-only role
    backend_roles = [
      "arn:aws:iam::779846821024:role/cadie-role"
    ]
  },
  "cadie_read_role" = {
    # Map service role to the custom read role
    backend_roles = [
      "arn:aws:iam::779846821024:role/cadie-role"
    ]
  },
  "cadie_admin_role" = {
    # Map admin role to the custom admin role
    backend_roles = [
      "arn:aws:iam::779846821024:role/cadie-role"
    ],
    users = ["cadie_admin_user"]  # Also explicitly map the admin user
  }
}
