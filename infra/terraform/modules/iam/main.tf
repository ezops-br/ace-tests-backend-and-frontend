data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions   = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
    sid    = "EC2AssumeRole"
  }
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions   = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    effect = "Allow"
    sid    = "ECSAssumeRole"
  }
}

resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  name               = var.role_name
  tags               = var.tags
}
