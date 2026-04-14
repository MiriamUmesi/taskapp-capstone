#!/bin/bash
source $(dirname "$0")/../config.env

echo "=== Building and pushing Docker images ==="

# Backend
cd ~/capstone-project-novara/taskapp_backend
docker build -t ${DOCKER_USERNAME}/taskapp-backend:1.0.0 .
docker push ${DOCKER_USERNAME}/taskapp-backend:1.0.0

# Frontend (VITE_API_URL required at build time)
cd ~/capstone-project-novara/taskapp_frontend
docker build --no-cache \
  --build-arg VITE_API_URL=https://api.${DOMAIN}/api \
  -t ${DOCKER_USERNAME}/taskapp-frontend:1.0.0 .
docker push ${DOCKER_USERNAME}/taskapp-frontend:1.0.0

echo "=== Done. Images pushed to Docker Hub ==="
