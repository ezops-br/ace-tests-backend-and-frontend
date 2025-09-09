output "frontend_s3_bucket_parameter_name" {
  description = "Parameter Store name for frontend S3 bucket"
  value       = aws_ssm_parameter.frontend_s3_bucket.name
}

output "frontend_cloudfront_distribution_id_parameter_name" {
  description = "Parameter Store name for CloudFront distribution ID"
  value       = aws_ssm_parameter.frontend_cloudfront_distribution_id.name
}

output "frontend_cloudfront_url_parameter_name" {
  description = "Parameter Store name for CloudFront URL"
  value       = aws_ssm_parameter.frontend_cloudfront_url.name
}
