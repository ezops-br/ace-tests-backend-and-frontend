provider "aws" { region = var.aws_region }

variable "aws_region" { type = string; default = "us-east-1" }
variable "subnets" { type = list(string); default = ["subnet-PLACEHOLDER1","subnet-PLACEHOLDER2"] }
variable "security_groups" { type = list(string); default = ["sg-PLACEHOLDER"] }
variable "db_username" { type = string; default = "dbadmin" }
variable "db_password" { type = string; sensitive = true }

module "ecr_backend" {
  source = "../../modules/ecr"
  repository_name = "ace-tests-backend"
  tags = { Environment = "production"; App = "ace-tests-backend" }
}

module "alb" {
  source = "../../modules/alb"
  load_balancer_name = "ace-tests-backend-alb"
  subnets = var.subnets
  security_groups = var.security_groups
}

module "ecs_backend" {
  source = "../../modules/ecs_fargate_service"
  cluster_name = "ace-tests-backend-cluster"
  service_name = "ace-tests-backend-service"
  image = module.ecr_backend.repository_url
  container_port = 3000
  subnets = var.subnets
  security_groups = var.security_groups
  desired_count = 2
  assign_public_ip = "DISABLED"
  execution_role_arn = ""
}

module "db" {
  source = "../../modules/rds"
  engine = "mysql"
  allocated_storage = 20
  instance_class = "db.t3.micro"
  name = "ace_tests_db"
  username = var.db_username
  password = var.db_password
  publicly_accessible = false
}

module "frontend_bucket" {
  source = "../../modules/s3_site"
  bucket_name = "ace-tests-frontend-site-production"
  enable_versioning = true
  enable_encryption = true
}

module "frontend_cloudfront" {
  source = "../../modules/cloudfront"
  origin_bucket_domain_name = module.frontend_bucket.bucket_domain_name
  alternative_domain_names = []
}

output "frontend_site_url" { value = module.frontend_cloudfront.distribution_domain_name }
