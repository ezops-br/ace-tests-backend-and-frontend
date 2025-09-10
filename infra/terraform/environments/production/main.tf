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

variable "github_repository" {
  type        = string
  description = "GitHub repository in format owner/repo (e.g., username/ace-tests-backend-and-frontend)"
  default     = "your-username/ace-tests-backend-and-frontend"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+$", var.github_repository))
    error_message = "GitHub repository must be in format 'owner/repo'."
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
  
  # Enable SSM parameter access for database password
  enable_ssm_parameter_access = true
  ssm_parameter_paths         = ["/${var.project_name}-service/database/*"]
  aws_region                  = var.aws_region
}

# IAM role for GitHub Actions frontend deployment
resource "aws_iam_role" "github_actions_frontend" {
  name = "${var.project_name}-github-actions-frontend"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:*"
          }
        }
      }
    ]
  })
  
  tags = {
    Environment = "production"
    App         = var.project_name
    Purpose     = "github-actions-frontend"
  }
}

# IAM policy for GitHub Actions frontend deployment
resource "aws_iam_role_policy" "github_actions_frontend" {
  name = "${var.project_name}-github-actions-frontend-policy"
  role = aws_iam_role.github_actions_frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          module.frontend_bucket.bucket_arn,
          "${module.frontend_bucket.bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetDistribution",
          "cloudfront:GetDistributionConfig"
        ]
        Resource = module.frontend_cloudfront.distribution_arn
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = [
          "arn:aws:ssm:${var.aws_region}:*:parameter/${var.project_name}/frontend/*"
        ]
      }
    ]
  })
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

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

# Update S3 bucket policy with CloudFront Origin Access Identity
resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = module.frontend_bucket.bucket_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontOriginAccessIdentity"
        Effect    = "Allow"
        Principal = {
          AWS = module.frontend_cloudfront.origin_access_identity_arn
        }
        Action   = "s3:GetObject"
        Resource = "${module.frontend_bucket.bucket_arn}/*"
      }
    ]
  })
}

output "frontend_site_url" {
  value = module.frontend_cloudfront.distribution_domain_name
}

output "frontend_cloudfront_distribution_id" {
  description = "CloudFront distribution ID for frontend"
  value       = module.frontend_cloudfront.distribution_id
}

# Parameter Store for frontend deployment
module "frontend_parameters" {
  source = "../../modules/parameter_store"
  
  project_name                = var.project_name
  s3_bucket_name             = module.frontend_bucket.bucket_name
  cloudfront_distribution_id = module.frontend_cloudfront.distribution_id
  cloudfront_url             = module.frontend_cloudfront.distribution_domain_name
  
  tags = {
    Environment = "production"
    App         = var.project_name
    Purpose     = "frontend-deployment"
  }
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

output "github_actions_frontend_role_arn" {
  description = "ARN of the IAM role for GitHub Actions frontend deployment"
  value       = aws_iam_role.github_actions_frontend.arn
}

output "frontend_parameter_names" {
  description = "Parameter Store names for frontend deployment"
  value = {
    s3_bucket_name             = module.frontend_parameters.frontend_s3_bucket_parameter_name
    cloudfront_distribution_id = module.frontend_parameters.frontend_cloudfront_distribution_id_parameter_name
    cloudfront_url             = module.frontend_parameters.frontend_cloudfront_url_parameter_name
  }
}

# Route53 Hosted Zone for ace-tests-front.ezopscloud.co (delegated subdomain)
resource "aws_route53_zone" "ace_tests_front" {
  name = "ace-tests-front.ezopscloud.co"
  
  tags = {
    Name        = "ace-tests-front.ezopscloud.co"
    Environment = "production"
    Project     = var.project_name
  }
}

# Data source to get the existing ezopscloud.co hosted zone
data "aws_route53_zone" "ezopscloud" {
  name = "ezopscloud.co"
}

# NS record in parent zone to delegate ace-tests-front.ezopscloud.co
resource "aws_route53_record" "ace_tests_front_ns" {
  zone_id = data.aws_route53_zone.ezopscloud.zone_id
  name    = "ace-tests-front.ezopscloud.co"
  type    = "NS"
  ttl     = 300
  records = aws_route53_zone.ace_tests_front.name_servers
}

# DNS Record pointing to CloudFront in the delegated zone
resource "aws_route53_record" "ace_tests_front" {
  zone_id = aws_route53_zone.ace_tests_front.zone_id
  name    = "ace-tests-front.ezopscloud.co"
  type    = "A"

  alias {
    name                   = module.frontend_cloudfront.distribution_domain_name
    zone_id                = module.frontend_cloudfront.distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

# Route53 Hosted Zone for ace-tests-back.ezopscloud.co (delegated subdomain)
resource "aws_route53_zone" "ace_tests_back" {
  name = "ace-tests-back.ezopscloud.co"
  
  tags = {
    Name        = "ace-tests-back.ezopscloud.co"
    Environment = "production"
    Project     = var.project_name
  }
}

# NS record in parent zone to delegate ace-tests-back.ezopscloud.co
resource "aws_route53_record" "ace_tests_back_ns" {
  zone_id = data.aws_route53_zone.ezopscloud.zone_id
  name    = "ace-tests-back.ezopscloud.co"
  type    = "NS"
  ttl     = 300
  records = aws_route53_zone.ace_tests_back.name_servers
}

# DNS Record pointing to ECS Load Balancer in the delegated zone
resource "aws_route53_record" "ace_tests_back" {
  zone_id = aws_route53_zone.ace_tests_back.zone_id
  name    = "ace-tests-back.ezopscloud.co"
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

# Output the hosted zone information
output "frontend_hosted_zone_id" {
  description = "Route53 hosted zone ID for ace-tests-front.ezopscloud.co"
  value = aws_route53_zone.ace_tests_front.zone_id
}

output "frontend_name_servers" {
  description = "Name servers for ace-tests-front.ezopscloud.co"
  value = aws_route53_zone.ace_tests_front.name_servers
}

output "frontend_domain" {
  description = "Frontend domain name"
  value = "ace-tests-front.ezopscloud.co"
}

output "backend_hosted_zone_id" {
  description = "Route53 hosted zone ID for ace-tests-back.ezopscloud.co"
  value = aws_route53_zone.ace_tests_back.zone_id
}

output "backend_name_servers" {
  description = "Name servers for ace-tests-back.ezopscloud.co"
  value = aws_route53_zone.ace_tests_back.name_servers
}

output "backend_domain" {
  description = "Backend domain name"
  value = "ace-tests-back.ezopscloud.co"
}
