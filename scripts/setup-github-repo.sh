#!/bin/bash

# Script to help set up the correct GitHub repository for OIDC

set -e

echo "🔧 GitHub Repository Setup for OIDC"
echo "=================================="
echo ""

# Get current repository from git
CURRENT_REPO=$(git remote get-url origin 2>/dev/null | sed 's/.*github.com[:/]\([^.]*\).*/\1/' || echo "")

if [ -n "$CURRENT_REPO" ]; then
    echo "📋 Current repository detected: $CURRENT_REPO"
    echo ""
    echo "To update the GitHub repository in Terraform:"
    echo "1. Edit infra/terraform/environments/production/terraform.tfvars"
    echo "2. Change the github_repository value to: $CURRENT_REPO"
    echo ""
    echo "Or run this command:"
    echo "sed -i 's/github_repository = \".*\"/github_repository = \"$CURRENT_REPO\"/' infra/terraform/environments/production/terraform.tfvars"
    echo ""
else
    echo "❌ Could not detect current repository from git remote"
    echo ""
    echo "Please manually set the GitHub repository:"
    echo "1. Edit infra/terraform/environments/production/terraform.tfvars"
    echo "2. Set github_repository to your repository in format 'owner/repo'"
    echo "   Example: github_repository = \"yourusername/ace-tests-backend-and-frontend\""
fi

echo ""
echo "ℹ️  Note: The GitHub repository is used for OIDC authentication"
echo "   Make sure it matches your actual GitHub repository name exactly."
