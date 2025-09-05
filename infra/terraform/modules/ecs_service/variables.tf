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

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "cpu" {
  type    = string
  default = "256"
}

variable "memory" {
  type    = string
  default = "512"
}

variable "execution_role_arn" {
  type    = string
  default = ""
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the target group to register the service with"
  default     = ""
}