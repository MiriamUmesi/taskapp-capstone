#!/bin/bash

echo "=== Setting up Kops state store ==="

export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create Kops state bucket
aws s3api create-bucket \
  --bucket taskapp-kops-state-${ACCOUNT_ID} \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket taskapp-kops-state-${ACCOUNT_ID} \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket taskapp-kops-state-${ACCOUNT_ID} \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

# Set environment variables permanently
cat >> ~/.bashrc << 'BASHRC'

# Kops environment variables
export ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export KOPS_STATE_STORE=s3://taskapp-kops-state-${ACCOUNT_ID}
export CLUSTER_NAME=taskapp.k8s.local
BASHRC

source ~/.bashrc

echo "=== Kops state store ready ==="
echo "KOPS_STATE_STORE=${KOPS_STATE_STORE}"
echo "CLUSTER_NAME=${CLUSTER_NAME}"
