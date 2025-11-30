#!/bin/bash

# Docker Cleanup Script
# Usage: ./scripts/clean-docker.sh [service_name]
# If service_name is provided, only clean that service
# Otherwise, clean all services

set -e  # Exit on error

# Configuration
SERVER_USER="${SERVER_USER:-tbu}"
SERVER_HOST="${SERVER_HOST:-14.253.124.159}"

SERVICE_NAME="${1:-all}"

echo "🧹 Starting Docker Cleanup for: ${SERVICE_NAME}..."

ssh ${SERVER_USER}@${SERVER_HOST} << EOF
  case "${SERVICE_NAME}" in
    backend|express|flask)
      echo "Cleaning backend services..."
      # Stop and remove backend containers
      sudo docker ps -a --filter "name=express_backend" --format "{{.Names}}" | xargs -r sudo docker stop || true
      sudo docker ps -a --filter "name=flask_backend" --format "{{.Names}}" | xargs -r sudo docker stop || true
      sudo docker ps -a --filter "name=express_backend" --format "{{.Names}}" | xargs -r sudo docker rm || true
      sudo docker ps -a --filter "name=flask_backend" --format "{{.Names}}" | xargs -r sudo docker rm || true
      # Remove backend images
      sudo docker images --filter "reference=complete-express_backend*" --format "{{.ID}}" | xargs -r sudo docker rmi || true
      sudo docker images --filter "reference=complete-flask_backend*" --format "{{.ID}}" | xargs -r sudo docker rmi || true
      ;;
    frontend|react)
      echo "Cleaning frontend service..."
      # Stop and remove frontend container
      sudo docker ps -a --filter "name=frontend" --format "{{.Names}}" | xargs -r sudo docker stop || true
      sudo docker ps -a --filter "name=frontend" --format "{{.Names}}" | xargs -r sudo docker rm || true
      # Remove frontend images
      sudo docker images --filter "reference=complete-frontend*" --format "{{.ID}}" | xargs -r sudo docker rmi || true
      ;;
    all|*)
      echo "Cleaning all services..."
      # Stop and remove all containers
      sudo docker ps -a --filter "name=express_backend" --filter "name=flask_backend" --filter "name=frontend" --format "{{.Names}}" | xargs -r sudo docker stop || true
      sudo docker ps -a --filter "name=express_backend" --filter "name=flask_backend" --filter "name=frontend" --format "{{.Names}}" | xargs -r sudo docker rm || true
      # Remove all images
      sudo docker images --filter "reference=complete-express_backend*" --format "{{.ID}}" | xargs -r sudo docker rmi || true
      sudo docker images --filter "reference=complete-flask_backend*" --format "{{.ID}}" | xargs -r sudo docker rmi || true
      sudo docker images --filter "reference=complete-frontend*" --format "{{.ID}}" | xargs -r sudo docker rmi || true
      # Clean up unused volumes
      echo "Cleaning unused volumes..."
      sudo docker volume prune -f || true
      ;;
  esac
  
  echo "✅ Cleanup completed"
  
  echo "Current containers:"
  sudo docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
  
  echo "Current images:"
  sudo docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
EOF

echo "✅ Docker cleanup completed!"

