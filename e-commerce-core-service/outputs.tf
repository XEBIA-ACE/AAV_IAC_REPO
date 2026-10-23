```hcl
output "bucket_id" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.ecommerce_core_service.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.ecommerce_core_service.arn
}
```

This Terraform configuration includes necessary resources for an S3 bucket with logging, versioning, and encryption settings enabled for a development environment. Adjust the `region` and `bucket_name` as required.