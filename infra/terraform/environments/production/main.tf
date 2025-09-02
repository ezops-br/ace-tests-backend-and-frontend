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

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  name_prefix = "ace-tests-backend"
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
  repository_name = "ace-tests-backend"
  tags            = { Environment = "production", App = "ace-tests-backend" }
}

module "alb" {
  source             = "../../modules/alb"
  load_balancer_name = "ace-tests-backend-alb"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnet_ids
  security_groups    = [module.vpc.alb_security_group_id]
}

module "ecs_backend" {
  source             = "../../modules/ecs_fargate_service"
  cluster_name       = "ace-tests-backend-cluster"
  service_name       = "ace-tests-backend-service"
  image              = module.ecr_backend.repository_url
  container_port     = 3000
  subnets            = module.vpc.private_subnet_ids
  security_groups    = [module.vpc.ecs_security_group_id]
  desired_count      = 2
  assign_public_ip   = false
  execution_role_arn = ""
}

module "db" {
  source                    = "../../modules/rds"
  engine                    = "mysql"
  allocated_storage         = 20
  instance_class            = "db.t3.micro"
  identifier                = "ace-tests-backend-db"
  username                  = var.db_username
  password                  = var.db_password
  publicly_accessible       = false
  vpc_security_group_ids    = [module.vpc.rds_security_group_id]
  subnet_ids                = module.vpc.private_subnet_ids
}

module "frontend_bucket" {
  source             = "../../modules/s3_site"
  bucket_name        = "ace-tests-frontend-site-production"
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
