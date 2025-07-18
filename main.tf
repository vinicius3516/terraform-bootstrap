# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Backend Local
terraform {
  backend "local" {}
}

# Locals
locals {
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Create a new Bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "tf-state-${var.environment}"
  tags   = local.tags

  lifecycle {
    prevent_destroy = true
  }
}

# Create an Ownership configuration for the Bucket
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Create an Server Side Encryption configuration for the Bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "server_side_encryption" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Create an Block Public Access
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create an versioning configuration for the Bucket
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Create an Dynamodb Table
resource "aws_dynamodb_table" "tf_lock" {
  name         = "terraform-locks-${var.environment}"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = local.tags
}