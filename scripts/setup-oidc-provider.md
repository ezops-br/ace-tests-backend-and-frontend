# GitHub OIDC Provider Setup

For the IAM role authentication to work, you need to set up a GitHub OIDC provider in AWS.

## Steps to Set Up OIDC Provider

1. **Go to AWS IAM Console**
   - Navigate to IAM > Identity providers
   - Click "Add provider"

2. **Configure OIDC Provider**
   - **Provider type**: OpenID Connect
   - **Provider URL**: `https://token.actions.githubusercontent.com`
   - **Audience**: `sts.amazonaws.com`
   - **Description**: `GitHub Actions OIDC Provider`

3. **Verify the Provider**
   - Click "Add provider"
   - The provider should now be available for use

## Alternative: Use AWS CLI

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

## Verify Setup

After setting up the OIDC provider, you can run:

```bash
./scripts/get-cloudfront-id.sh
```

This will give you the IAM role ARN to use as the `AWS_ROLE_ARN` secret in GitHub.

## Troubleshooting

If you get OIDC-related errors:
1. Verify the OIDC provider is set up correctly
2. Check that the GitHub repository name matches exactly
3. Ensure the IAM role trust policy allows the correct repository
