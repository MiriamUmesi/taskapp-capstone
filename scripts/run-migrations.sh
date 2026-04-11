#!/bin/bash

echo "=== Running database migrations ==="

# Get the first running backend pod
BACKEND_POD=$(kubectl get pod -n taskapp -l app=backend -o jsonpath='{.items[0].metadata.name}')

if [ -z "$BACKEND_POD" ]; then
  echo "ERROR: No backend pod found. Is the backend deployed?"
  exit 1
fi

echo "Running migrations on pod: $BACKEND_POD"
kubectl exec -n taskapp $BACKEND_POD -- alembic upgrade head

echo "=== Migrations complete ==="
