#!/bin/bash

echo "🚀 ACE Tests - Playwright Testing"
echo "================================="

# Check if Node.js is installed
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js version: $NODE_VERSION"
else
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if Docker is running
if command -v docker &> /dev/null; then
    echo "✅ Docker is available"
else
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Install Playwright (only for browser testing)
echo "🌐 Installing Playwright for browser testing..."
npm install playwright --save-dev

# Install system dependencies for Playwright
echo "🔧 Installing system dependencies for Playwright..."
sudo npx playwright install-deps

# Install Playwright browsers
echo "🌐 Installing Playwright browsers..."
npx playwright install chromium

# Run the tests
echo "🧪 Running Playwright tests..."
echo ""

node test-playwright.js

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ All tests passed successfully!"
else
    echo ""
    echo "❌ Tests failed!"
    exit 1
fi
