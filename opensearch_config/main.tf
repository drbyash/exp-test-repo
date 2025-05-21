# OpenSearch Admin Role
resource "opensearch_role" "admin_role" {
  role_name           = var.admin_role_name
  description         = var.admin_role_description
  cluster_permissions = var.admin_cluster_permissions

  index_permissions {
    index_patterns  = var.admin_index_patterns
    allowed_actions = var.admin_index_actions
  }

  tenant_permissions {
    tenant_patterns = var.admin_tenant_patterns
    allowed_actions = var.admin_tenant_actions
  }
}

# OpenSearch Read-only Role
resource "opensearch_role" "readonly_role" {
  role_name           = var.readonly_role_name
  description         = var.readonly_role_description
  cluster_permissions = var.readonly_cluster_permissions

  index_permissions {
    index_patterns  = var.readonly_index_patterns
    allowed_actions = var.readonly_index_actions
  }

  tenant_permissions {
    tenant_patterns = var.readonly_tenant_patterns
    allowed_actions = var.readonly_tenant_actions
  }
}

# Role Mappings
resource "opensearch_roles_mapping" "admin_mapping" {
  role_name     = var.admin_role_name
  description   = var.admin_mapping_description
  backend_roles = var.admin_backend_roles
}

resource "opensearch_roles_mapping" "readonly_mapping" {
  role_name     = var.readonly_role_name
  description   = var.readonly_mapping_description
  backend_roles = var.readonly_backend_roles
}

# OpenSearch Cadie Role
resource "opensearch_role" "cadie_role" {
  role_name           = var.cadie_role_name
  description         = var.cadie_role_description
  cluster_permissions = var.cadie_cluster_permissions

  index_permissions {
    index_patterns  = var.cadie_index_patterns
    allowed_actions = var.cadie_index_actions
  }

  tenant_permissions {
    tenant_patterns = var.cadie_tenant_patterns
    allowed_actions = var.cadie_tenant_actions
  }
}

# Cadie Role Mapping
resource "opensearch_roles_mapping" "cadie_mapping" {
  role_name     = var.cadie_role_name
  description   = var.cadie_mapping_description
  backend_roles = var.cadie_backend_roles
}
