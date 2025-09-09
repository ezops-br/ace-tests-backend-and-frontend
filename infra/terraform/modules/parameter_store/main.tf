resource "aws_ssm_parameter" "frontend_s3_bucket" {
  name  = "/${var.project_name}/frontend/s3-bucket"
  type  = "String"
  value = var.s3_bucket_name
  description = "S3 bucket name for frontend deployment"
  
  tags = var.tags
}

resource "aws_ssm_parameter" "frontend_cloudfront_distribution_id" {
  name  = "/${var.project_name}/frontend/cloudfront-distribution-id"
  type  = "String"
  value = var.cloudfront_distribution_id
  description = "CloudFront distribution ID for frontend"
  
  tags = var.tags
}

resource "aws_ssm_parameter" "frontend_cloudfront_url" {
  name  = "/${var.project_name}/frontend/cloudfront-url"
  type  = "String"
  value = var.cloudfront_url
  description = "CloudFront distribution URL for frontend"
  
  tags = var.tags
}
