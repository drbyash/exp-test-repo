variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
  default     = "us-east-1"
}

variable "redis_cluster_id" {
  description = "ID of the existing Redis cluster"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to use for resource naming"
  type        = string
}

variable "redis_user_password" {
  description = "Password for Redis token authentication user"
  type        = string
  sensitive   = true
}
