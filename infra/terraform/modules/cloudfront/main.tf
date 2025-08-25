terraform {
  required_providers {
    aws = { source = "hashicorp/aws"; version = "~> 5.0" }
  }
  required_version = ">= 1.5.0"
}

variable "origin_bucket_domain_name" { type = string }
variable "alternative_domain_names" { type = list(string); default = [] }

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for S3 site"
}

resource "aws_cloudfront_distribution" "this" {
  enabled = true
  origins {
    domain_name = var.origin_bucket_domain_name
    origin_id   = "s3-site-origin"
    s3_origin_config { origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path }
  }

  enabled                   = true
  is_ipv6_enabled           = true
  default_root_object       = "index.html"

  default_cache_behavior {
    target_origin_id       = "s3-site-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
  }

  price_class = "PriceClass_All"

  viewer_certificate { cloudfront_default_certificate = true }
}

output "distribution_domain_name" { value = aws_cloudfront_distribution.this.domain_name }
output "distribution_id" { value = aws_cloudfront_distribution.this.id }
