# DB Subnet Group
resource "aws_db_subnet_group" "this" {
  count = var.db_subnet_group_name != "" ? 0 : 1

  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.identifier}-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  allocated_storage       = var.allocated_storage
  engine                  = var.engine
  instance_class          = var.instance_class
  identifier              = var.identifier
  username                = var.username
  password                = var.password
  publicly_accessible     = var.publicly_accessible
  skip_final_snapshot     = true
  multi_az                = false
  parameter_group_name    = "default.${var.engine}"
  vpc_security_group_ids  = var.vpc_security_group_ids
  db_subnet_group_name    = var.db_subnet_group_name != "" ? var.db_subnet_group_name : aws_db_subnet_group.this[0].name

  tags = {
    Name = var.identifier
  }
}
