# Frontend Deployment Guide

This document explains how to deploy the frontend to AWS S3 and CloudFront using GitHub Actions.

## Prerequisites

1. **Terraform Infrastructure**: The S3 bucket and CloudFront distribution must be created first
2. **GitHub Secrets**: Required secrets must be configured in your repository
3. **AWS Permissions**: The GitHub Actions runner needs appropriate AWS permissions

## Required GitHub Secrets

Configure this secret in your GitHub repository (Settings > Secrets and variables > Actions):

- `AWS_ROLE_ARN`: IAM role ARN for GitHub Actions frontend deployment

## Getting the Deployment Information

After running Terraform to create the infrastructure, get the deployment information:

```bash
# Run the helper script
./scripts/get-cloudfront-id.sh

# Or manually get the role ARN from Terraform output
cd infra/terraform/environments/production
terraform output github_actions_frontend_role_arn
```

## Parameter Store Integration

The deployment workflow automatically retrieves configuration from AWS Parameter Store:

- **S3 Bucket Name**: `/ace-tests-back-front/frontend/s3-bucket`
- **CloudFront Distribution ID**: `/ace-tests-back-front/frontend/cloudfront-distribution-id`
- **CloudFront URL**: `/ace-tests-back-front/frontend/cloudfront-url`

These parameters are automatically created by Terraform and updated whenever the infrastructure changes.

## Deployment Process

The deployment workflow (`.github/workflows/deploy-frontend.yml`) automatically:

1. **Triggers on**:
   - Push to `main` or `develop` branches (when frontend files change)
   - Pull requests to `main` (for testing)
   - Manual workflow dispatch

2. **Deploys**:
   - Retrieves configuration from AWS Parameter Store
   - Syncs frontend files to S3 bucket
   - Sets appropriate content types and cache headers
   - Invalidates CloudFront cache automatically
   - Verifies deployment success

## File Structure

The workflow deploys all files from the `frontend/` directory except:
- `Dockerfile` (not needed for static hosting)
- `README.md` and `LICENSE` (documentation files)
- `infra/` directory (infrastructure files)

## Cache Configuration

- **Static assets** (CSS, images): 1 year cache (`max-age=31536000`)
- **HTML files**: No cache (`max-age=0, must-revalidate`)

## Manual Deployment

To deploy manually:

```bash
# Configure AWS credentials
aws configure

# Sync files to S3
aws s3 sync frontend/ s3://ace-tests-back-front-frontend-site-production/ --delete

# Invalidate CloudFront cache (optional)
aws cloudfront create-invalidation --distribution-id YOUR_DISTRIBUTION_ID --paths "/*"
```

## Troubleshooting

### S3 Bucket Not Found
- Ensure Terraform has been applied to create the infrastructure
- Check the bucket name in the workflow matches your Terraform output

### CloudFront Cache Not Invalidating
- Verify Parameter Store parameters are correctly set
- Check IAM role permissions for CloudFront invalidation
- Ensure the GitHub Actions role has the correct permissions

### Files Not Updating
- Check CloudFront cache settings
- Verify cache invalidation is working
- Consider using different cache behaviors for different file types

## Monitoring

- Check GitHub Actions logs for deployment status
- Monitor CloudFront metrics in AWS Console
- Verify S3 bucket contents after deployment
