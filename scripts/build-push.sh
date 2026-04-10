#!/bin/bash

echo "=== Building and pushing Docker images ==="

# Backend
cd ~/capstone-project-novara/taskapp_backend
docker build -t enzoputachi/taskapp-backend:1.0.0 .
docker push enzoputachi/taskapp-backend:1.0.0

# Frontend
cd ~/capstone-project-novara/taskapp_frontend
docker build -t enzoputachi/taskapp-frontend:1.0.0 .
docker push enzoputachi/taskapp-frontend:1.0.0

echo "=== Done. Images pushed to Docker Hub ==="
