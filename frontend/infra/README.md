Infra: S3 + CloudFront hosting (Terraform)

This branch refactors Terraform to use a modular layout and removes the previous GitHub Actions pipeline.

Structure:
- terraform/: entry point (backend.tf, variables.tf, versions.tf, outputs.tf)
- modules/s3_site/: S3 bucket module
- modules/cloudfront/: CloudFront + OAI module

CI pipeline (.github/workflows/deploy-site.yml) has been removed from this branch as requested. Deploys/uploads should be handled manually or reintroduced later with a deployment strategy that fits the environment.

Required repository secrets (if you reintroduce CI later):
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION
- SITE_BUCKET
- TF_STATE_BUCKET
- TF_LOCK_TABLE

Follow terraform/README.md for backend bootstrap and usage.
