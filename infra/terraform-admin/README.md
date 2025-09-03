# Terraform Admin Configuration

This directory contains the Terraform configuration for creating the remote state backend infrastructure.

## Purpose

This configuration creates:
- S3 bucket for storing Terraform state files
- DynamoDB table for state locking
- Proper security configurations (encryption, public access blocking)

## Usage

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Plan the deployment:**
   ```bash
   terraform plan
   ```

3. **Apply the configuration:**
   ```bash
   terraform apply
   ```

4. **Get the backend configuration:**
   ```bash
   terraform output backend_config
   ```

## Important Notes

- This configuration should be applied **before** setting up remote state in other Terraform configurations
- The S3 bucket and DynamoDB table names are configurable via variables
- This directory is **NOT** committed to version control (see .gitignore)
- After applying, use the `backend_config` output to configure remote state in other Terraform configurations

## Backend Configuration

After applying this configuration, you can use the following backend configuration in your other Terraform configurations:

```hcl
terraform {
  backend "s3" {
    bucket         = "ace-tests-back-front-tfstate"
    key            = "path/to/your/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ace-tests-back-front-tfstate-locks"
    encrypt        = true
  }
}
```

## Security Features

- S3 bucket has versioning enabled
- S3 bucket has server-side encryption enabled
- S3 bucket blocks all public access
- DynamoDB table uses pay-per-request billing
- All resources are properly tagged
