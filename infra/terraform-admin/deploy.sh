#!/bin/bash

# Terraform Admin Deployment Script
# This script deploys the remote state backend infrastructure

set -e

echo "🚀 Starting Terraform Admin Deployment..."

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install Terraform first."
    exit 1
fi

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Plan the deployment
echo "📋 Planning deployment..."
terraform plan

# Ask for confirmation
echo ""
echo "⚠️  This will create S3 bucket and DynamoDB table for Terraform state management."
read -p "Do you want to proceed? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Apply the configuration
    echo "🔧 Applying configuration..."
    terraform apply -auto-approve
    
    echo ""
    echo "✅ Deployment completed successfully!"
    echo ""
    echo "📋 Backend Configuration:"
    terraform output backend_config
    
    echo ""
    echo "💡 Next steps:"
    echo "1. Copy the backend configuration above"
    echo "2. Update your main Terraform configurations to use remote state"
    echo "3. Run 'terraform init' in your main configurations to migrate state"
else
    echo "❌ Deployment cancelled."
    exit 1
fi
