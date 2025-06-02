# Redis IAM Authentication Configuration

This configuration enables IAM authentication for an existing ElastiCache Redis cluster.

## Prerequisites

- An existing ElastiCache Redis cluster
- An existing IAM role that will be used for authentication
- Terraform installed
- AWS CLI configured with appropriate permissions

## Configuration Files

- `main.tf`: Creates ElastiCache user and user group with IAM authentication and updates the existing Redis cluster
- `iam.tf`: Adds necessary IAM policies to the existing role
- `variables.tf`: Defines input variables
- `outputs.tf`: Defines output values
- `terraform.tfvars.example`: Example variable values (rename to terraform.tfvars and update with your values)

## Usage

1. Update the `terraform.tfvars` file with your specific values:
   ```
   aws_region = "your-region"
   redis_cluster_id = "your-redis-cluster-id"
   name_prefix = "your-app-name"
   existing_iam_role_arn = "your-iam-role-arn"
   ```

2. Initialize Terraform:
   ```
   terraform init
   ```

3. Apply the configuration:
   ```
   terraform apply
   ```

## Connecting to Redis with IAM Authentication

To connect to Redis using IAM authentication, your application needs to:

1. Generate an authentication token using the AWS SDK
2. Use the token to authenticate with Redis

Example using Python:

```python
import boto3
import redis

# Generate auth token
elasticache = boto3.client('elasticache')
auth_token = elasticache.generate_auth_token(
    ReplicationGroupId='your-redis-cluster-id',
    UserName='IAMAuthUser'
)

# Connect to Redis using the token
redis_client = redis.Redis(
    host='your-redis-endpoint',
    port=6379,
    ssl=True,
    password=auth_token
)

# Test the connection
print(redis_client.ping())
```

## Notes

- IAM authentication requires Redis 6.0 or later
- Transit encryption must be enabled (TLS)
- The IAM role must have the `elasticache:Connect` permission for the specific user
