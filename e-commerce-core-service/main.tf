```hcl
resource "aws_s3_bucket" "ecommerce_core_service" {
  bucket = var.bucket_name
  acl    = "private"

  tags = {
    ManagedBy     = "ace"
    Environment   = "development"
    Project       = "6f2fbdc5-d238-42ca-93ca-888e3233a026"
    Service       = "E-Commerce Core Service"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.ecommerce_core_service.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.ecommerce_core_service.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_logging" "logging" {
  bucket = aws_s3_bucket.ecommerce_core_service.id

  target_bucket = aws_s3_bucket.ecommerce_core_service.id
  target_prefix = "log/"
}
```