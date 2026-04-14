#!/bin/bash
source $(dirname "$0")/../config.env

echo "=== Setting up Terraform remote state ==="

echo "Account ID: ${AWS_ACCOUNT_ID}"

aws s3api create-bucket \
  --bucket taskapp-terraform-state-${AWS_ACCOUNT_ID} \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket taskapp-terraform-state-${AWS_ACCOUNT_ID} \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket taskapp-terraform-state-${AWS_ACCOUNT_ID} \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws dynamodb create-table \
  --table-name taskapp-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1

echo "=== Terraform state infrastructure ready ==="
