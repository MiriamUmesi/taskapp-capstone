#!/bin/bash

echo "=== Installing cert-manager ==="

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

echo "Waiting for cert-manager pods to be ready..."
kubectl wait --namespace cert-manager \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/instance=cert-manager \
  --timeout=180s

echo "=== Applying cluster issuer ==="
kubectl apply -f k8s/cluster-issuer.yaml

echo "=== cert-manager installed and configured ==="
