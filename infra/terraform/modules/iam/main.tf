data "aws_iam_policy_document" "default" {
  statement {
    actions   = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
    sid    = "ExampleAssumeRole"
  }
}

resource "aws_iam_role" "this" {
  name               = "terraform-module-role"
  assume_role_policy = var.assume_role_policy != "" ? var.assume_role_policy : data.aws_iam_policy_document.default.json
}
