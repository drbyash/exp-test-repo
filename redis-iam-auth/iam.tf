# Reference to the existing IAM role
data "aws_iam_role" "existing_role" {
  arn = var.existing_iam_role_arn
}

# Adding ElastiCache IAM authentication policy to the existing role
resource "aws_iam_role_policy" "redis_auth_policy" {
  name   = "redis-iam-auth-policy"
  role   = data.aws_iam_role.existing_role.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticache:Connect"
        ],
        Resource = [
          "arn:aws:elasticache:${var.aws_region}:${data.aws_caller_identity.current.account_id}:user:${aws_elasticache_user.iam_auth_user.user_id}"
        ]
      }
    ]
  })
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}
