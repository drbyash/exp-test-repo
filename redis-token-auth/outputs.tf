output "redis_endpoint" {
  description = "Redis primary endpoint"
  value       = data.aws_elasticache_replication_group.existing_redis.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Redis reader endpoint"
  value       = data.aws_elasticache_replication_group.existing_redis.reader_endpoint_address
}

output "redis_port" {
  description = "Redis port"
  value       = data.aws_elasticache_replication_group.existing_redis.port
}

output "token_user_id" {
  description = "ElastiCache token user ID"
  value       = aws_elasticache_user.token_auth_user.user_id
}

output "default_user_id" {
  description = "ElastiCache default user ID"
  value       = aws_elasticache_user.default_user.user_id
}

output "user_group_id" {
  description = "ElastiCache user group ID"
  value       = aws_elasticache_user_group.redis_token_users.user_group_id
}
