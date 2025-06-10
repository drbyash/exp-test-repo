provider "aws" {
  region = var.aws_region
}

# Reference to the existing Redis cluster
data "aws_elasticache_replication_group" "existing_redis" {
  replication_group_id = var.redis_cluster_id
}

# Create a user group for token authentication
resource "aws_elasticache_user_group" "redis_token_users" {
  engine        = "REDIS"
  user_group_id = "${var.name_prefix}-token-users"
  
  user_ids = [
    aws_elasticache_user.token_auth_user.user_id,
    aws_elasticache_user.default_user.user_id
  ]
}

# Create a user with token (password) authentication
resource "aws_elasticache_user" "token_auth_user" {
  user_id       = "${var.name_prefix}-token-user"
  user_name     = "TokenAuthUser"
  access_string = "on ~* -@all +@read +@write"
  engine        = "REDIS"
  
  # Using password authentication instead of IAM
  authentication_mode {
    type      = "password"
    passwords = [var.redis_user_password]
  }
}

# Create the required default user
resource "aws_elasticache_user" "default_user" {
  user_id       = "${var.name_prefix}-default-user"
  user_name     = "default"
  access_string = "on ~* +@all"  # You can adjust permissions as needed
  engine        = "REDIS"
  
  # Using password authentication
  authentication_mode {
    type      = "password"
    passwords = [var.redis_default_user_password]
  }
}

# Update the existing Redis cluster to use the token user group
resource "aws_elasticache_replication_group" "update_redis" {
  replication_group_id = data.aws_elasticache_replication_group.existing_redis.replication_group_id
  user_group_ids       = [aws_elasticache_user_group.redis_token_users.id]
  
  # Preserve existing configuration
  description                = data.aws_elasticache_replication_group.existing_redis.description
  node_type                  = data.aws_elasticache_replication_group.existing_redis.node_type
  num_cache_clusters         = length(data.aws_elasticache_replication_group.existing_redis.member_clusters)
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
      snapshot_retention_limit,
      subnet_group_name,
      security_group_ids,
      multi_az_enabled,
      port,
      kms_key_id,
      auth_token,
      preferred_cache_cluster_azs,
      data_tiering_enabled,
      auto_minor_version_upgrade,
      final_snapshot_identifier,
      global_replication_group_id,
      ip_discovery,
      network_type,
      log_delivery_configuration
    ]
  }
}
