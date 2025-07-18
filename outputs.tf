output "s3_bucket_name" {
  description = "The name of the S3 bucket for Terraform state storage."
  value       = aws_s3_bucket.bucket.bucket
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking."
  value       = aws_dynamodb_table.tf_lock.name
}