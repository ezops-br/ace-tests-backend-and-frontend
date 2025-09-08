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

variable "enable_ssm_parameter_access" {
  type        = bool
  description = "Whether to enable SSM parameter access for the role"
  default     = false
}

variable "ssm_parameter_paths" {
  type        = list(string)
  description = "List of SSM parameter paths to allow access to"
  default     = []
}

variable "aws_region" {
  type        = string
  description = "AWS region for SSM parameter ARNs"
  default     = "us-east-1"
}