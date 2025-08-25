terraform {
  required_providers {
    aws = { source = "hashicorp/aws"; version = "~> 5.0" }
  }
  required_version = ">= 1.5.0"
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "tags" {
  description = "Optional tags for the repository"
  type        = map(string)
  default     = {}
}

resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

output "repository_url" {
  value = aws_ecr_repository.this.repository_url
}
output "repository_name" {
  value = aws_ecr_repository.this.name
}
output "repository_arn" {
  value = aws_ecr_repository.this.arn
}
