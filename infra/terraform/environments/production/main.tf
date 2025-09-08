terraform {
  backend "s3" {
    bucket         = "ace-tests-back-front-tfstate"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    # profile = "ace-tests"
    use_lockfile   = true
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  # profile = "ace-tests"
}

variable "project_name" {
  type        = string
  description = "Name of the project used for resource naming"
  default     = "ace-tests-back-front"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "db_username" {
  type    = string
  default = "dbadmin"
}

variable "db_password" {
  type      = string
  sensitive = true
  nullable  = false

  validation {
    condition     = length(var.db_password) > 0
    error_message = "db_password must be provided via TF_VAR_db_password or another non-empty input."
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  name_prefix = var.project_name
  vpc_cidr    = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  enable_nat_gateway   = true
  app_port = 3000
  db_port  = 3306
}

module "ecr_backend" {
  source          = "../../modules/ecr"
  repository_name = var.project_name
  tags            = { Environment = "production", App = var.project_name }
}

module "ecs_execution_role" {
  source = "../../modules/iam"
  
  role_name = "${var.project_name}-ecs-execution-role"
  service   = "ecs"
  tags      = { Environment = "production", App = var.project_name }
}

module "alb" {
  source             = "../../modules/alb"
  load_balancer_name = "${var.project_name}-alb"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnet_ids
  security_groups    = [module.vpc.alb_security_group_id]
}

module "ecs_backend" {
  source             = "../../modules/ecs_service"
  cluster_name       = "${var.project_name}-cluster"
  service_name       = "${var.project_name}-service"
  image              = module.ecr_backend.repository_url
  container_port     = 3000
  subnets            = module.vpc.private_subnet_ids
  security_groups    = [module.vpc.ecs_security_group_id]
  desired_count      = 1
  min_size           = 1
  max_size           = 3
  desired_capacity   = 2
  instance_type      = "t3.medium"
  cpu                = "256"
  memory             = "512"
  execution_role_arn = module.ecs_execution_role.role_arn
  target_group_arn   = module.alb.alb_target_group_arn
  aws_region         = var.aws_region
  log_retention_days = 14
  environment        = "production"
  
  # Database environment variables
  db_host     = module.db.endpoint
  db_port     = 3306
  db_name     = module.db.db_name
  db_username = module.db.username
  db_password = var.db_password
  db_engine   = module.db.engine
}

module "db" {
  source                    = "../../modules/rds"
  engine                    = "mysql"
  allocated_storage         = 20
  instance_class            = "db.t3.micro"
  identifier                = "${var.project_name}-db"
  db_name                   = "ace_tests_production"
  username                  = var.db_username
  password                  = var.db_password
  publicly_accessible       = false
  vpc_security_group_ids    = [module.vpc.rds_security_group_id]
  subnet_ids                = module.vpc.private_subnet_ids
}

module "frontend_bucket" {
  source             = "../../modules/s3_site"
  bucket_name        = "${var.project_name}-frontend-site-production"
  enable_versioning  = true
  enable_encryption  = true
}

module "frontend_cloudfront" {
  source                    = "../../modules/cloudfront"
  origin_bucket_domain_name = module.frontend_bucket.bucket_domain_name
  alternative_domain_names  = []
}

output "frontend_site_url" {
  value = module.frontend_cloudfront.distribution_domain_name
}

output "ecs_execution_role_arn" {
  description = "ARN of the ECS execution role"
  value       = module.ecs_execution_role.role_arn
}

output "ecs_execution_role_name" {
  description = "Name of the ECS execution role"
  value       = module.ecs_execution_role.role_name
}

output "ecs_task_execution_role_policy_arn" {
  description = "ARN of the ECS Task Execution Role Policy"
  value       = module.ecs_execution_role.ecs_task_execution_role_policy_arn
}

output "ecs_task_role_policy_arn" {
  description = "ARN of the ECS Task Role Policy"
  value       = module.ecs_execution_role.ecs_task_role_policy_arn
}

output "ecs_log_group_arn" {
  description = "ARN of the CloudWatch log group for ECS service"
  value       = module.ecs_backend.log_group_arn
}

output "ecs_log_group_name" {
  description = "Name of the CloudWatch log group for ECS service"
  value       = module.ecs_backend.log_group_name
}

output "database_endpoint" {
  description = "Database endpoint"
  value       = module.db.endpoint
}

output "database_identifier" {
  description = "Database identifier"
  value       = module.db.identifier
}

output "database_name" {
  description = "Database name"
  value       = module.db.db_name
}
