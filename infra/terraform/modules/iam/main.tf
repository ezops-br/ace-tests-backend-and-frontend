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

# Attach ECS Task Execution Role Policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  count      = var.service == "ecs" ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attach ECS Full Access Policy (optional, for task role)
resource "aws_iam_role_policy_attachment" "ecs_full_access_policy" {
  count      = var.service == "ecs" && var.attach_task_role_policy ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}