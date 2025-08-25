resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for S3 site"
}

resource "aws_cloudfront_distribution" "this" {
  enabled = true

  origin {
    domain_name = var.origin_bucket_domain_name
    origin_id   = "s3-site-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = "s3-site-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
  }

  price_class = "PriceClass_All"

  viewer_certificate { cloudfront_default_certificate = true }
}
