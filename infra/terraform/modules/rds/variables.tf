variable "engine" {
  type    = string
  default = "mysql"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "identifier" {
  type    = string
  default = "ace-tests-backend-db"
}

variable "username" {
  type    = string
  default = "dbadmin"
}

variable "password" {
  type      = string
  sensitive = true
}

variable "publicly_accessible" {
  type    = bool
  default = false
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate with the RDS instance"
  type        = list(string)
  default     = []
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
  default     = []
}

variable "db_name" {
  description = "Name of the initial database to create"
  type        = string
  default     = "ace_tests_db"
}