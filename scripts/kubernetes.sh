#!/bin/bash

echo "=== Installing NGINX Ingress Controller ==="
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml

echo "=== Waiting for ingress controller to be ready ==="
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "=== Installing cert-manager ==="
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

echo "=== Waiting for cert-manager to be ready ==="
kubectl wait --namespace cert-manager \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/instance=cert-manager \
  --timeout=120s

echo "=== Deploying application ==="
kubectl apply -f ~/taskapp-capstone/k8s/namespace.yaml
kubectl apply -f ~/taskapp-capstone/k8s/secrets.yaml
kubectl apply -f ~/taskapp-capstone/k8s/cluster-issuer.yaml
kubectl apply -f ~/taskapp-capstone/k8s/backendDeployment.yaml
kubectl apply -f ~/taskapp-capstone/k8s/frontendDeployment.yaml
kubectl apply -f ~/taskapp-capstone/k8s/ingress.yaml

echo "=== Checking pod status ==="
kubectl get pods -n taskapp

echo "=== Getting ingress address ==="
kubectl get ingress -n taskapp

echo "=== Done ==="
