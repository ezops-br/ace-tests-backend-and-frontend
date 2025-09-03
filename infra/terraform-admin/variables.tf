variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ace-tests-back-front"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "ace-tests-back-front-tfstate"
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "ace-tests-back-front-tfstate-locks"
}
