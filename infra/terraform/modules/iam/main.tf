terraform {
  required_providers {
    aws = { source = "hashicorp/aws"; version = "~> 5.0" }
  }
  required_version = ">= 1.5.0"
}

variable "assume_role_policy" { type = string; default = "" }

resource "aws_iam_role" "this" {
  name               = "terraform-module-role"
  assume_role_policy = var.assume_role_policy != "" ? var.assume_role_policy : data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  statement {
    actions   = ["sts:AssumeRole"]
    principals { type = "Service"; identifiers = ["ec2.amazonaws.com"] }
    effect = "Allow"
    sid    = "ExampleAssumeRole"
  }
}

output "role_arn" { value = aws_iam_role.this.arn }
