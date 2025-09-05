variable "assume_role_policy" {
  type    = string
  default = ""
}

variable "role_name" {
  type        = string
  description = "Name of the IAM role"
}

variable "service" {
  type        = string
  description = "Service type (ec2, ecs, etc.)"
  default     = "ec2"
}

variable "attach_task_role_policy" {
  type        = bool
  description = "Whether to attach the ECS task role policy"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the IAM role"
  default     = {}
}