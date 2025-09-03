@echo off
REM Terraform Admin Deployment Script for Windows
REM This script deploys the remote state backend infrastructure

echo 🚀 Starting Terraform Admin Deployment...

REM Check if terraform is installed
terraform --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Terraform is not installed. Please install Terraform first.
    pause
    exit /b 1
)

REM Initialize Terraform
echo 📦 Initializing Terraform...
terraform init
if %errorlevel% neq 0 (
    echo ❌ Terraform init failed.
    pause
    exit /b 1
)

REM Plan the deployment
echo 📋 Planning deployment...
terraform plan
if %errorlevel% neq 0 (
    echo ❌ Terraform plan failed.
    pause
    exit /b 1
)

REM Ask for confirmation
echo.
echo ⚠️  This will create S3 bucket and DynamoDB table for Terraform state management.
set /p confirm="Do you want to proceed? (y/N): "

if /i "%confirm%"=="y" (
    REM Apply the configuration
    echo 🔧 Applying configuration...
    terraform apply -auto-approve
    
    if %errorlevel% neq 0 (
        echo ❌ Terraform apply failed.
        pause
        exit /b 1
    )
    
    echo.
    echo ✅ Deployment completed successfully!
    echo.
    echo 📋 Backend Configuration:
    terraform output backend_config
    
    echo.
    echo 💡 Next steps:
    echo 1. Copy the backend configuration above
    echo 2. Update your main Terraform configurations to use remote state
    echo 3. Run 'terraform init' in your main configurations to migrate state
) else (
    echo ❌ Deployment cancelled.
)

pause
