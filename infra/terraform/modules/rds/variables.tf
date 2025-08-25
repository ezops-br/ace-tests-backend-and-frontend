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

variable "name" {
  type    = string
  default = "appdb"
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
