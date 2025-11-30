#!/bin/bash

# Backend Deployment Script (Express + Flask)
# Usage: ./scripts/deploy-backend.sh

set -e  # Exit on error

# Configuration
SERVER_USER="${SERVER_USER:-tbu}"
SERVER_HOST="${SERVER_HOST:-14.253.124.159}"
SERVER_PATH="${SERVER_PATH:-/home/tbu/complete}"

echo "🚀 Starting Backend Deployment..."

# Step 1: Sync files to server
echo "📤 Step 1: Syncing files to server..."
rsync -avz --progress \
  --exclude='node_modules/' \
  --exclude='.vscode/' \
  --exclude='.git/' \
  --exclude='.gitignore' \
  --exclude='backend-flask/data/' \
  --exclude='backend-flask/venv/' \
  --exclude='backend-flask/model/' \
  --exclude='backend-flask/copernicus_temp_data/' \
  --exclude='backend-flask/export_full_raw.csv' \
  --exclude='backend-flask/notebook.ipynb' \
  --exclude='backend-flask/prediction_module/__pycache__/' \
  --exclude='backend-flask/__pycache__/' \
  --exclude='*.log' \
  --exclude='.env*' \
  --exclude='dist/' \
  --exclude='build/' \
  --exclude='frontend/' \
  ./ ${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}/

echo "✅ Files synced successfully"

# Step 2: Clean old containers and images
echo "🧹 Step 2: Cleaning old containers and images..."
ssh ${SERVER_USER}@${SERVER_HOST} << 'EOF'
  # Stop and remove old backend containers
  echo "Stopping old containers..."
  sudo docker ps -a --filter "name=express_backend" --format "{{.Names}}" | xargs -r sudo docker stop || true
  sudo docker ps -a --filter "name=flask_backend" --format "{{.Names}}" | xargs -r sudo docker stop || true
  
  echo "Removing old containers..."
  sudo docker ps -a --filter "name=express_backend" --format "{{.Names}}" | xargs -r sudo docker rm || true
  sudo docker ps -a --filter "name=flask_backend" --format "{{.Names}}" | xargs -r sudo docker rm || true
  
  # Remove old backend images
  echo "Removing old images..."
  sudo docker images --filter "reference=complete-express_backend*" --format "{{.ID}}" | xargs -r sudo docker rmi || true
  sudo docker images --filter "reference=complete-flask_backend*" --format "{{.ID}}" | xargs -r sudo docker rmi || true
  
  # Clean up unused volumes (be careful - this removes unused volumes)
  echo "Cleaning unused volumes..."
  sudo docker volume prune -f || true
  
  echo "✅ Cleanup completed"
EOF

# Step 3: Deploy with Docker Compose
echo "🐳 Step 3: Deploying with Docker Compose..."
ssh ${SERVER_USER}@${SERVER_HOST} << EOF
  cd ${SERVER_PATH}
  echo "Building and starting backend services..."
  sudo docker compose up -d --build express_backend flask_backend postgres_db
  echo "✅ Backend services deployed"
EOF

# Step 4: Health check
echo "🏥 Step 4: Health check..."
ssh ${SERVER_USER}@${SERVER_HOST} << 'EOF'
  sleep 10
  echo "Container status:"
  sudo docker ps --filter "name=express_backend" --filter "name=flask_backend" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
EOF

echo "✅ Backend deployment completed!"

