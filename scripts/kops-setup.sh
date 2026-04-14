#!/bin/bash
source $(dirname "$0")/../config.env

echo "=== Setting up Kops state store ==="

aws s3api create-bucket \
  --bucket taskapp-kops-state-${AWS_ACCOUNT_ID} \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket taskapp-kops-state-${AWS_ACCOUNT_ID} \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket taskapp-kops-state-${AWS_ACCOUNT_ID} \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

cat >> ~/.bashrc << BASHRC

# Kops environment variables
export KOPS_STATE_STORE=${KOPS_STATE_STORE}
export CLUSTER_NAME=${CLUSTER_NAME}
BASHRC

source ~/.bashrc

echo "=== Kops state store ready ==="
echo "KOPS_STATE_STORE=${KOPS_STATE_STORE}"
echo "CLUSTER_NAME=${CLUSTER_NAME}"
