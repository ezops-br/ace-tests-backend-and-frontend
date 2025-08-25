Terraform modules and example manifests for the ace-tests application.

Structure:
- modules/: reusable modules (ecr, alb, ecs_fargate_service, rds, s3_site, cloudfront, iam, monitoring)
- environments/: example environment wiring (production)
- examples/: example tfvars and usage
- root/terraform-backend.tf: remote state backend config (example)

IMPORTANT: Replace placeholder values (subnet IDs, SG IDs, ARNs, secrets) before running terraform apply. Use Secrets Manager/SSM for sensitive values.
