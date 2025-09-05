#!/bin/bash

echo "🚀 Quick Test - ACE Tests Full Stack"
echo "===================================="

# Check if Docker is running
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not available. Please install Docker."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not available. Please install Docker Compose."
    exit 1
fi

# Start services
echo "📦 Starting services..."
docker-compose up -d

# Wait for services
echo "⏳ Waiting for services..."
sleep 20

# Quick tests
echo "🔍 Running quick tests..."

# Test backend
if curl -s http://localhost:3000/messages > /dev/null; then
    echo "✅ Backend: OK"
else
    echo "❌ Backend: FAILED"
fi

# Test frontend
if curl -s http://localhost > /dev/null; then
    echo "✅ Frontend: OK"
else
    echo "❌ Frontend: FAILED"
fi

# Show status
echo "📋 Service Status:"
docker-compose ps

echo ""
echo "🌐 URLs:"
echo "  Frontend: http://localhost"
echo "  Backend: http://localhost:3000"

echo ""
echo "To stop: docker-compose down"
