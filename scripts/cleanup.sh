#!/bin/bash

echo "=== Starting cleanup ==="

# Step 1 — Delete the Kops cluster first
echo "Deleting Kops cluster..."
kops delete cluster --name=${CLUSTER_NAME} --yes

# Step 2 — Destroy Terraform infrastructure
echo "Destroying Terraform infrastructure..."
cd ~/taskapp-capstone/terraform/root
terraform destroy -auto-approve

echo "=== Cleanup complete ==="
echo "Note: S3 buckets and DynamoDB table preserved for reuse."
echo "To delete them manually run:"
echo "  aws s3 rb s3://taskapp-terraform-state-${ACCOUNT_ID} --force"
echo "  aws s3 rb s3://taskapp-kops-state-${ACCOUNT_ID} --force"
echo "  aws dynamodb delete-table --table-name taskapp-terraform-locks"
