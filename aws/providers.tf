provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

terraform {
  required_version = ">= 1.00"
  backend "s3" {
    region               = "us-east-1"
    workspace_key_prefix = "tf-infra"
  }
}
