variable "repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}
