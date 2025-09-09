#!/bin/bash

# Script to get deployment information after Terraform deployment
# This helps set up GitHub secrets and provides deployment information

set -e

echo "Getting deployment information from Terraform output..."

# Change to the production environment directory
cd infra/terraform/environments/production

# Get the GitHub Actions role ARN
ROLE_ARN=$(terraform output -raw github_actions_frontend_role_arn 2>/dev/null || echo "")

if [ -z "$ROLE_ARN" ]; then
    echo "❌ Error: Could not get GitHub Actions role ARN"
    echo "Make sure Terraform has been applied and the infrastructure exists"
    exit 1
fi

echo "✅ GitHub Actions Role ARN: $ROLE_ARN"
echo ""
echo "📋 To set up the GitHub secret:"
echo "1. Go to your GitHub repository"
echo "2. Navigate to Settings > Secrets and variables > Actions"
echo "3. Add a new repository secret:"
echo "   Name: AWS_ROLE_ARN"
echo "   Value: $ROLE_ARN"
echo ""
echo "🔧 Parameter Store Parameters:"
echo "The following parameters are automatically created in AWS Parameter Store:"
terraform output -json frontend_parameter_names | jq -r 'to_entries[] | "   \(.key): \(.value)"'
echo ""
echo "🌐 Frontend URL:"
terraform output -raw frontend_site_url
echo ""
echo "ℹ️  Note: The workflow will automatically retrieve S3 bucket and CloudFront"
echo "   information from Parameter Store, so no additional secrets are needed!"
