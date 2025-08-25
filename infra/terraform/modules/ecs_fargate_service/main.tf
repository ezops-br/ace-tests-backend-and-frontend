terraform {
  required_providers {
    aws = { source = "hashicorp/aws"; version = "~> 5.0" }
  }
  required_version = ">= 1.5.0"
}

variable "cluster_name" { type = string }
variable "service_name" { type = string }
variable "image" { type = string }
variable "container_port" { type = number; default = 3000 }
variable "subnets" { type = list(string) }
variable "security_groups" { type = list(string); default = [] }
variable "desired_count" { type = number; default = 2 }
variable "assign_public_ip" { type = string; default = "DISABLED" }
variable "execution_role_arn" { type = string; default = "" }

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.image
      essential = true
      portMappings = [ { containerPort = var.container_port; hostPort = var.container_port; protocol = "tcp" } ]
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = var.assign_public_ip
  }

  depends_on = [aws_ecs_task_definition.this]
}

output "service_name" { value = aws_ecs_service.this.name }
output "task_definition_arn" { value = aws_ecs_task_definition.this.arn }
output "cluster_id" { value = aws_ecs_cluster.this.id }
