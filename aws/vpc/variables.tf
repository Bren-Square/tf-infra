# Required Variables
variable "app_name" {
  description = "The name of your app."
  type        = string
}

variable "container_version" {
  description = "The version of your container."
  type        = string
}

variable "private_subnet_tags" {
  description = "A map of tags for your private subnets."
  type        = map(any)
}

variable "public_subnet_tags" {
  description = "A map of tags for your public subnets."
  type        = map(any)
}

variable "tags" {
  description = "A map of tags for your resources."
  type        = map(any)
}

variable "tier" {
  description = "The tier you want to use for your vpc."
  type        = string
}

# Defaulted but overideable variables
variable "aws_profile" {
  default     = "default"
  description = "The profile for your aws credentials. default"
  type        = string
}

variable "aws_region" {
  default     = "us-east-1"
  description = "the default region you wish to use. us-east-1"
  type        = string
}
