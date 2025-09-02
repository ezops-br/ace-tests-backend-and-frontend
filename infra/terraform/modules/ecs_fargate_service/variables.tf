variable "cluster_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "image" {
  type = string
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "subnets" {
  type = list(string)
}

variable "security_groups" {
  type    = list(string)
  default = []
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "assign_public_ip" {
  type    = bool
  default = false
}

variable "execution_role_arn" {
  type    = string
  default = ""
}
