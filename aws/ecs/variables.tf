# Required
variable "app_name" {}
variable "container_version" {}
variable "tier" {}

# Defaulted but overideable
variable "aws_region" {
  default = "us-east-1"
}
