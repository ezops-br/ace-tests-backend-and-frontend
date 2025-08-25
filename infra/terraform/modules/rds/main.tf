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
