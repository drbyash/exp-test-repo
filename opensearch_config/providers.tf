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
  aws_profile           = var.aws_profile
  insecure              = var.insecure
  aws_service_name      = "es"  # Use "es" for Amazon OpenSearch Service
}
