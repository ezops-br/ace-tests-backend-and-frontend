#!/bin/bash

echo "🚀 Testing ACE Tests Full Stack with Docker Compose"
echo "====================================================="

# Check if Docker is running
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not available. Please install Docker."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not available. Please install Docker Compose."
    exit 1
fi

# Start the services
echo "📦 Starting all services with Docker Compose..."
docker-compose up -d

if [ $? -ne 0 ]; then
    echo "❌ Failed to start services!"
    exit 1
fi

echo "✅ Services started successfully!"

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Test database connection
echo "🔍 Testing database connection..."
if curl -s http://localhost:3000/messages > /dev/null; then
    echo "✅ Database connection successful!"
    curl -s http://localhost:3000/messages | jq . 2>/dev/null || echo "Response received (jq not available for formatting)"
else
    echo "❌ Database connection failed!"
fi

# Test POST endpoint
echo "🔍 Testing POST /messages..."
POST_RESPONSE=$(curl -s -X POST http://localhost:3000/messages \
  -H "Content-Type: application/json" \
  -d '{"content":"Hello from Docker Compose test!"}')

if echo "$POST_RESPONSE" | grep -q "id"; then
    echo "✅ POST successful!"
    echo "$POST_RESPONSE" | jq . 2>/dev/null || echo "$POST_RESPONSE"
else
    echo "❌ POST failed: $POST_RESPONSE"
fi

# Test GET endpoint again
echo "🔍 Testing GET /messages after POST..."
if curl -s http://localhost:3000/messages > /dev/null; then
    echo "✅ GET after POST successful!"
    curl -s http://localhost:3000/messages | jq . 2>/dev/null || echo "Response received (jq not available for formatting)"
else
    echo "❌ GET after POST failed!"
fi

# Test frontend
echo "🔍 Testing frontend..."
if curl -s http://localhost > /dev/null; then
    echo "✅ Frontend is accessible!"
else
    echo "❌ Frontend test failed!"
fi

# Show service status
echo "📋 Service status:"
docker-compose ps

echo ""
echo "🌐 Access URLs:"
echo "  Frontend (direct): http://localhost"
echo "  Backend API: http://localhost:3000"
echo "  Database: localhost:3306"

echo ""
echo "Press any key to stop services and clean up..."
read -n 1 -s

echo "🧹 Stopping and cleaning up..."
docker-compose down -v

echo "✅ Test completed!"
