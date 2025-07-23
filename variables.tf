variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
}
variable "environment" {
  description = "The environment for which the resources are being created (dev, staging, prod)"
  type        = string
}
variable "project_id" {
  description = "The project id for use in resource naming"
  type = string
}