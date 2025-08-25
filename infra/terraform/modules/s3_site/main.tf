terraform {
  required_providers {
    aws = { source = "hashicorp/aws"; version = "~> 5.0" }
  }
  required_version = ">= 1.5.0"
}

variable "bucket_name" { type = string }
variable "enable_versioning" { type = bool; default = true }
variable "enable_encryption" { type = bool; default = true }

resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name
  acl    = "private"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id
  versioning_configuration { status = var.enable_versioning ? "Enabled" : "Disabled" }
}

output "bucket_domain_name" { value = aws_s3_bucket.site.bucket_domain_name }
output "bucket_arn" { value = aws_s3_bucket.site.arn }
