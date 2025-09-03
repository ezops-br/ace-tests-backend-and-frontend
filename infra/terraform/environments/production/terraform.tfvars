# production terraform.tfvars
#
# Best practices:
# - Keep ONLY non-secret values in this file.
# - Provide secrets (e.g., db_password) via environment variables or your CI secret store.
#   Examples:
#     PowerShell (Windows):  $env:TF_VAR_db_password = "<secure-password>"
#     Bash (Linux/macOS):    export TF_VAR_db_password="<secure-password>"

project_name = "ace-tests-back-front"
aws_region = "us-east-1"

# Networking is now managed by the VPC module
# No need to specify subnets or security groups manually

# Database (non-secret values only)
db_username = "dbadmin"
# Do NOT set db_password here. Supply it via TF_VAR_db_password.
