# OpenSearch Roles and Mappings Configuration

This Terraform configuration creates OpenSearch roles and role mappings for access control.

## Resources Created

1. **OpenSearch Roles**:
   - `admin_role`: A role with full administrative access
   - `readonly_role`: A role with read-only permissions for monitoring and analytics

2. **Role Mappings**:
   - `admin_mapping`: Maps the IAM role `mycompany-dev-admin` to the admin role
   - `readonly_mapping`: Maps the IAM role `mycompany-dev-analyst` to the readonly role

## Prerequisites

- Terraform 0.14.0 or later
- AWS CLI configured with appropriate credentials
- Access to an Amazon OpenSearch Service domain

## Usage

1. Update the `terraform.tfvars` file with your OpenSearch endpoint and AWS configuration:

```hcl
opensearch_url = "https://your-opensearch-endpoint.region.es.amazonaws.com"
aws_region     = "us-east-1"
aws_profile    = "default"
```

2. Initialize the Terraform configuration:

```bash
terraform init
```

3. Review the planned changes:

```bash
terraform plan
```

4. Apply the configuration:

```bash
terraform apply
```

## Customization

You can customize the roles and mappings by modifying the variables in `terraform.tfvars`.

## File Structure

- `main.tf`: Contains the main resource definitions
- `variables.tf`: Defines all variables used in the configuration
- `terraform.tfvars`: Contains the values for the variables
- `providers.tf`: Configures the OpenSearch provider
- `README.md`: This documentation file
