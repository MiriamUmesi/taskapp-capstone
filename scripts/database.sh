#!/bin/bash

echo "=== Running database migrations ==="

# Get the backend pod name
POD=$(kubectl get pod -n taskapp -l app=backend -o jsonpath="{.items[0].metadata.name}")

echo "Running migrations on pod: $POD"

# Run alembic migrations inside the backend pod
kubectl exec -n taskapp $POD -- alembic upgrade head

echo "=== Database migrations complete ==="
