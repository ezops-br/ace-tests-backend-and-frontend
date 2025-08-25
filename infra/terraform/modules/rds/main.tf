terraform {
  required_providers {
    aws = { source = "hashicorp/aws"; version = "~> 5.0" }
  }
  required_version = ">= 1.5.0"
}

variable "engine" { type = string; default = "mysql" }
variable "allocated_storage" { type = number; default = 20 }
variable "instance_class" { type = string; default = "db.t3.micro" }
variable "name" { type = string; default = "appdb" }
variable "username" { type = string; default = "dbadmin" }
variable "password" { type = string; sensitive = true }
variable "publicly_accessible" { type = bool; default = false }

resource "aws_db_instance" "this" {
  allocated_storage    = var.allocated_storage
  engine               = var.engine
  instance_class       = var.instance_class
  name                 = var.name
  username             = var.username
  password             = var.password
  publicly_accessible  = var.publicly_accessible
  skip_final_snapshot  = true
  multi_az             = false
  parameter_group_name = "default.${var.engine}"
  tags = { Name = var.name }
}

output "endpoint" { value = aws_db_instance.this.address }
output "arn" { value = aws_db_instance.this.arn }
