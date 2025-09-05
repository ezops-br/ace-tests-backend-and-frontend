output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.this.name
}

output "role_id" {
  description = "ID of the IAM role"
  value       = aws_iam_role.this.id
}

output "ecs_task_execution_role_policy_arn" {
  description = "ARN of the ECS Task Execution Role Policy"
  value       = var.service == "ecs" ? "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy" : null
}

output "ecs_task_role_policy_arn" {
  description = "ARN of the ECS Task Role Policy"
  value       = var.service == "ecs" && var.attach_task_role_policy ? "arn:aws:iam::aws:policy/AmazonECS_FullAccess" : null
}
