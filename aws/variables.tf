locals {
  app_name = "tf-infra"
  tier = terraform.workspace
  
  tags = {
    Name        = local.tier
    Owner       = "bts"
    Department  = "eds"
    GitRepo     = "cicd-demo"
    ProjectName = "cicd-demo"
    Tier        = local.tier
  }

  public_subnet_tags = merge(local.tags, {Status = "public"})
  private_subnet_tags = merge(local.tags, {Status = "private"})
}

variable "container_version" {
  type = string
}

variable "aws_region" {
  default = "us-east-1"
}

variable "aws_profile" {
  default = "default"
}

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
