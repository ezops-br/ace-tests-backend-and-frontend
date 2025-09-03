# Terraform Admin Deployment Script for PowerShell
# This script deploys the remote state backend infrastructure

Write-Host "🚀 Starting Terraform Admin Deployment..." -ForegroundColor Green

# Check if terraform is installed
try {
    $terraformVersion = terraform --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform not found"
    }
} catch {
    Write-Host "❌ Terraform is not installed. Please install Terraform first." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Initialize Terraform
Write-Host "📦 Initializing Terraform..." -ForegroundColor Yellow
terraform init
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform init failed." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Plan the deployment
Write-Host "📋 Planning deployment..." -ForegroundColor Yellow
terraform plan
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform plan failed." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Ask for confirmation
Write-Host ""
Write-Host "⚠️  This will create S3 bucket and DynamoDB table for Terraform state management." -ForegroundColor Yellow
$confirm = Read-Host "Do you want to proceed? (y/N)"

if ($confirm -eq "y" -or $confirm -eq "Y") {
    # Apply the configuration
    Write-Host "🔧 Applying configuration..." -ForegroundColor Yellow
    terraform apply -auto-approve
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Terraform apply failed." -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    Write-Host ""
    Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Backend Configuration:" -ForegroundColor Cyan
    terraform output backend_config
    
    Write-Host ""
    Write-Host "💡 Next steps:" -ForegroundColor Cyan
    Write-Host "1. Copy the backend configuration above"
    Write-Host "2. Update your main Terraform configurations to use remote state"
    Write-Host "3. Run 'terraform init' in your main configurations to migrate state"
} else {
    Write-Host "❌ Deployment cancelled." -ForegroundColor Red
}

Read-Host "Press Enter to exit"
