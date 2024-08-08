terraform {
  required_version = "~> 1.9.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.61.0"
    }
  }
  backend "local" {}
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      env       = "eks-sandbox"
      ManagedBy = "Terraform"
    }
  }
}