variable "origin_bucket_domain_name" {
  type = string
}

variable "alternative_domain_names" {
  type    = list(string)
  default = []
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the SSL certificate to use for CloudFront"
  default     = null
}