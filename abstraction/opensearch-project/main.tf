# main.tf
terraform {
  required_providers {
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "~> 2.0"
    }
  }
}

provider "opensearch" {
  url                = var.opensearch_endpoint
  aws_region         = var.aws_region
  username           = var.opensearch_username
  password           = var.opensearch_password
  insecure          = var.insecure
  healthcheck       = false
  sign_aws_requests = false
}

module "opensearch_access_control" {
  source = "./modules/opensearch_access_control"
  application_config = var.application_config
}
