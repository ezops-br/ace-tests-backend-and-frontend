output "endpoint" {
  value = aws_db_instance.this.address
}

output "arn" {
  value = aws_db_instance.this.arn
}

output "identifier" {
  value = aws_db_instance.this.identifier
}

output "username" {
  value = aws_db_instance.this.username
}

output "engine" {
  value = aws_db_instance.this.engine
}

output "db_name" {
  value = aws_db_instance.this.db_name
}