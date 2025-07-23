variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
}
variable "environment" {
  description = "The environment for which the resources are being created (dev, staging, prod)"
  type        = string
}
variable "account_id" {
  description = "The account id for use in resource naming"
  type        = string
}