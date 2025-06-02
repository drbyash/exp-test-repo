provider "aws" {
  region = var.aws_region
}

# Reference to the existing Redis cluster
data "aws_elasticache_replication_group" "existing_redis" {
  replication_group_id = var.redis_cluster_id
}

# Create a user group for IAM authentication
resource "aws_elasticache_user_group" "redis_iam_users" {
  engine        = "REDIS"
  user_group_id = "${var.name_prefix}-iam-users"
  
  user_ids = [
    aws_elasticache_user.iam_auth_user.user_id
  ]
}

# Create a user for IAM authentication
resource "aws_elasticache_user" "iam_auth_user" {
  user_id       = "${var.name_prefix}-iam-user"
  user_name     = "IAMAuthUser"
  access_string = "on ~* -@all +@read +@connection -@write"
  engine        = "REDIS"
  authentication_mode {
    type = "iam"
  }
}

# Update the existing Redis cluster to use the IAM user group
resource "aws_elasticache_replication_group" "update_redis" {
  replication_group_id = data.aws_elasticache_replication_group.existing_redis.replication_group_id
  user_group_ids       = [aws_elasticache_user_group.redis_iam_users.id]
  
  # Preserve existing configuration
  description                = data.aws_elasticache_replication_group.existing_redis.description
  node_type                  = data.aws_elasticache_replication_group.existing_redis.node_type
  num_cache_clusters         = data.aws_elasticache_replication_group.existing_redis.number_cache_clusters
  automatic_failover_enabled = data.aws_elasticache_replication_group.existing_redis.automatic_failover_enabled
  
  # If using cluster mode
  dynamic "cluster_mode" {
    for_each = data.aws_elasticache_replication_group.existing_redis.cluster_enabled ? [1] : []
    content {
      replicas_per_node_group = data.aws_elasticache_replication_group.existing_redis.replicas_per_node_group
      num_node_groups         = data.aws_elasticache_replication_group.existing_redis.num_node_groups
    }
  }
  
  # Keep existing security settings
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  
  # Apply changes immediately
  apply_immediately = true
  
  lifecycle {
    ignore_changes = [
      engine_version,
      parameter_group_name,
      maintenance_window,
      snapshot_window,
      snapshot_retention_limit
    ]
  }
}
