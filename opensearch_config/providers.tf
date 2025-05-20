terraform {
  required_version = ">= 0.14.0"
  required_providers {
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = ">= 2.0.0"
    }
  }
}

provider "opensearch" {
  url                   = var.opensearch_url
  aws_region            = var.aws_region
  insecure              = var.insecure
  healthcheck = false
username              = var.opensearch_username
password              = var.opensearch_password 
sign_aws_requests     = false
}
