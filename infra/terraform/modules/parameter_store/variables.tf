variable "project_name" {
  type        = string
  description = "Name of the project used for parameter naming"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name for frontend deployment"
}

variable "cloudfront_distribution_id" {
  type        = string
  description = "CloudFront distribution ID for frontend"
}

variable "cloudfront_url" {
  type        = string
  description = "CloudFront distribution URL for frontend"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the parameters"
  default     = {}
}
