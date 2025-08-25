# Terraform CI Usage

This repository contains a GitHub Actions workflow to run Terraform plan and (optionally) apply.

How it runs:
- The workflow triggers on changes under `infra/terraform/**` targeting `main`, on pull requests to `main`, and can be manually triggered via `workflow_dispatch`.
- The `terraform-ci` job runs terraform fmt, init (with backend disabled), validate, and plan. The plan output is uploaded as an artifact named `tfplan`.
- The `apply` job only runs when the workflow is manually dispatched with the `apply` input set to `true`. It downloads the previously uploaded plan artifact and runs `terraform apply` using the saved plan.

Secrets required:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

Apply gating:
- The apply job is configured to use the `production` environment. Protect the environment in repository settings to require approvals before deployment.

