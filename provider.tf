terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
      
    }
  }
}

# Configure provider
provider "aws" {
  region      = "us-east-1"
  endpoints {
    ec2            = var.environment == "localstack" ? "http://localhost:4566" : null
    iam            = var.environment == "localstack" ? "http://localhost:4566" : null
    s3             = var.environment == "localstack" ? "http://localhost:4566" : null
    route53        = var.environment == "localstack" ? "http://localhost:4566" : null
  }
}