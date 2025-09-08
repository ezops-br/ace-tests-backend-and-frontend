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
  default = 1
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

variable "aws_region" {
  type        = string
  description = "AWS region for CloudWatch logs"
  default     = "us-east-1"
}

variable "log_retention_days" {
  type        = number
  description = "Number of days to retain CloudWatch logs"
  default     = 7
}

variable "environment" {
  type        = string
  description = "Environment name for tagging"
  default     = "production"
}

# Database environment variables
variable "db_host" {
  type        = string
  description = "Database host endpoint"
  default     = ""
}

variable "db_port" {
  type        = number
  description = "Database port"
  default     = 3306
}

variable "db_name" {
  type        = string
  description = "Database name"
  default     = ""
}

variable "db_username" {
  type        = string
  description = "Database username"
  default     = ""
}

variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
  default     = ""
}

variable "db_engine" {
  type        = string
  description = "Database engine (mysql, postgres, etc.)"
  default     = "mysql"
}