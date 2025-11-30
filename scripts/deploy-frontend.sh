#!/bin/bash

# Frontend Deployment Script (React)
# Usage: ./scripts/deploy-frontend.sh

set -e  # Exit on error

# Configuration
SERVER_USER="${SERVER_USER:-tbu}"
SERVER_HOST="${SERVER_HOST:-14.253.124.159}"
SERVER_PATH="${SERVER_PATH:-/home/tbu/complete}"

echo "🚀 Starting Frontend Deployment..."

# Step 1: Sync files to server
echo "📤 Step 1: Syncing files to server..."
rsync -avz --progress \
  --exclude='node_modules/' \
  --exclude='.vscode/' \
  --exclude='.git/' \
  --exclude='.gitignore' \
  --exclude='dist/' \
  --exclude='build/' \
  --exclude='backend-express/' \
  --exclude='backend-flask/' \
  --exclude='*.log' \
  --exclude='.env*' \
  ./ ${SERVER_USER}@${SERVER_HOST}:${SERVER_PATH}/

echo "✅ Files synced successfully"

# Step 2: Clean old containers and images
echo "🧹 Step 2: Cleaning old containers and images..."
ssh ${SERVER_USER}@${SERVER_HOST} << 'EOF'
  # Stop and remove old frontend container
  echo "Stopping old frontend container..."
  sudo docker ps -a --filter "name=frontend" --format "{{.Names}}" | xargs -r sudo docker stop || true
  
  echo "Removing old frontend container..."
  sudo docker ps -a --filter "name=frontend" --format "{{.Names}}" | xargs -r sudo docker rm || true
  
  # Remove old frontend images
  echo "Removing old frontend images..."
  sudo docker images --filter "reference=complete-frontend*" --format "{{.ID}}" | xargs -r sudo docker rmi || true
  
  # Clean up unused volumes (be careful - this removes unused volumes)
  echo "Cleaning unused volumes..."
  sudo docker volume prune -f || true
  
  echo "✅ Cleanup completed"
EOF

# Step 3: Deploy with Docker Compose
echo "🐳 Step 3: Deploying with Docker Compose..."
ssh ${SERVER_USER}@${SERVER_HOST} << EOF
  cd ${SERVER_PATH}
  echo "Building and starting frontend service..."
  sudo docker compose up -d --build frontend
  echo "✅ Frontend service deployed"
EOF

# Step 4: Health check
echo "🏥 Step 4: Health check..."
ssh ${SERVER_USER}@${SERVER_HOST} << 'EOF'
  sleep 10
  echo "Container status:"
  sudo docker ps --filter "name=frontend" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
EOF

echo "✅ Frontend deployment completed!"

