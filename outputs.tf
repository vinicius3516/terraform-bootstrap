output "s3_bucket_name" {
  description = "The name of the S3 bucket for Terraform state storage."
  value       = aws_s3_bucket.bucket.bucket
}