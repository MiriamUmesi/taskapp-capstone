cat > ~/taskapp-capstone/scripts/build-push.sh << 'EOF'
#!/bin/bash

echo "=== Building and pushing Docker images ==="

# Backend
cd ~/capstone-project-novara/taskapp_backend
docker build -t enzoputachi/taskapp-backend:1.0.0 .
docker push enzoputachi/taskapp-backend:1.0.0

# Frontend (VITE_API_URL required at build time)
cd ~/capstone-project-novara/taskapp_frontend
docker build --no-cache \
  --build-arg VITE_API_URL=https://api.enzoputachi.site/api \
  -t enzoputachi/taskapp-frontend:1.0.2 .
docker push enzoputachi/taskapp-frontend:1.0.2

echo "=== Done. Images pushed to Docker Hub ==="
EOF

chmod +x ~/taskapp-capstone/scripts/build-push.sh