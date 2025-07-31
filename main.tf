# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Backend Local (mantém local aqui)
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
  bucket = "tf-state-${var.environment}-${var.unique_id}"
  tags   = local.tags

  lifecycle {
    prevent_destroy = true
  }
}

# Bucket Ownership
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "server_side_encryption" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
