# GitHub Actions Deployment

This repository includes a GitHub Actions workflow that automatically builds and deploys the application to AWS ECS.

## Required GitHub Secrets

To use this workflow, you need to configure the following secrets in your GitHub repository:

### AWS Credentials
1. Go to your repository on GitHub
2. Navigate to Settings → Secrets and variables → Actions
3. Add the following repository secrets:

- `AWS_ACCESS_KEY_ID`: Your AWS access key ID
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key

### How to get AWS credentials:

1. **Create an IAM user** (if you don't have one):
   - Go to AWS IAM Console
   - Create a new user with programmatic access
   - Attach the following policies:
     - `AmazonEC2ContainerRegistryFullAccess`
     - `AmazonECS_FullAccess`
     - `AmazonEC2FullAccess` (for VPC and security group management)

2. **Create access keys**:
   - Go to the IAM user you created
   - Go to Security credentials tab
   - Create access key
   - Copy the Access Key ID and Secret Access Key

## Workflow Triggers

The workflow will run on:
- Push to `main` or `develop` branches
- Pull requests to `main` branch

## What the workflow does:

1. **Build**: Builds the Docker image using the Dockerfile
2. **Push to ECR**: Pushes the image to Amazon Elastic Container Registry
3. **Deploy to ECS**: Updates the ECS service with the new image
4. **Verify**: Confirms the deployment was successful

## Environment Variables

The workflow uses these environment variables (configured in the workflow file):
- `AWS_REGION`: us-east-1
- `ECR_REPOSITORY`: ace-tests-back-front
- `ECS_SERVICE`: ace-tests-back-front-service
- `ECS_CLUSTER`: ace-tests-back-front-cluster
- `ECS_TASK_DEFINITION`: ace-tests-back-front-service

## Prerequisites

Before running the workflow, ensure:
1. Your AWS infrastructure is deployed using Terraform
2. The ECR repository exists
3. The ECS cluster and service are created
4. The ECS task definition exists

## Troubleshooting

If the deployment fails:
1. Check the GitHub Actions logs for specific error messages
2. Verify that all AWS resources exist and are properly configured
3. Ensure the IAM user has the necessary permissions
4. Check that the ECS service is in a healthy state
