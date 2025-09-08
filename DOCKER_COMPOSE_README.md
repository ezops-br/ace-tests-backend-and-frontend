# Docker Compose Testing Setup

This setup allows you to test the complete ACE Tests application stack locally using Docker Compose.

## 🏗️ Architecture

The Docker Compose setup includes:

- **MySQL Database**: Stores application data
- **Backend API**: Node.js Express server
- **Frontend**: Nginx serving static files
- **Nginx Reverse Proxy**: Routes traffic between frontend and backend

## 🚀 Quick Start

### Option 1: Quick Test
```powershell
.\test-compose-quick.ps1
```

### Option 2: Full Interactive Test
```powershell
.\test-compose.ps1
```

### Option 3: Manual Commands
```powershell
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs

# Stop services
docker-compose down
```

## 🌐 Access URLs

- **Frontend (Direct)**: http://localhost
- **Backend API**: http://localhost:3000
- **Nginx Proxy**: http://localhost:8080
- **Database**: localhost:3306

## 📋 API Endpoints

### Backend API (http://localhost:3000)

- `GET /messages` - Get all messages
- `POST /messages` - Create a new message
- `GET /messages/:id` - Get message by ID

### Example API Usage

```powershell
# Get all messages
Invoke-RestMethod -Uri "http://localhost:3000/messages" -Method GET

# Create a message
$body = @{ content = "Hello from Docker Compose!" } | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:3000/messages" -Method POST -Body $body -ContentType "application/json"
```

## 🔧 Configuration

### Environment Variables

The backend uses these environment variables:
- `DB_HOST`: Database host (default: mysql)
- `DB_USER`: Database user (default: app_user)
- `DB_PASSWORD`: Database password (default: app_password)
- `DB_NAME`: Database name (default: ace_tests)
- `PORT`: Backend port (default: 3000)

### Database

- **Root Password**: password
- **Database**: ace_tests
- **User**: app_user
- **Password**: app_password

## 🐛 Troubleshooting

### Check Service Status
```powershell
docker-compose ps
```

### View Logs
```powershell
# All services
docker-compose logs

# Specific service
docker-compose logs backend
docker-compose logs mysql
docker-compose logs frontend
```

### Restart Services
```powershell
docker-compose restart
```

### Clean Up
```powershell
# Stop and remove containers
docker-compose down

# Stop, remove containers, and volumes
docker-compose down -v
```

## 📁 File Structure

```
├── docker-compose.yml          # Main compose file
├── nginx.conf                  # Nginx reverse proxy config
├── test-compose.ps1           # Full interactive test
├── test-compose-quick.ps1     # Quick test
└── DOCKER_COMPOSE_README.md   # This file
```

## 🔄 Development Workflow

1. **Start services**: `docker-compose up -d`
2. **Make changes** to your code
3. **Rebuild backend**: `docker-compose up -d --build backend`
4. **Test changes** using the API endpoints
5. **Stop services**: `docker-compose down`

## 📊 Health Checks

The setup includes health checks for:
- **MySQL**: Checks if database is responding
- **Backend**: Checks if API is responding

Services will wait for dependencies to be healthy before starting.
