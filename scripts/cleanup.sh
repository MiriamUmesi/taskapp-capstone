#!/bin/bash
source $(dirname "$0")/../config.env

echo "=== Starting cleanup ==="

echo "Deleting Kops cluster..."
kops delete cluster --name=${CLUSTER_NAME} --state=${KOPS_STATE_STORE} --yes

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY

echo "Destroying Terraform infrastructure..."
cd ~/taskapp-client-dobsi894/terraform/root
terraform destroy -auto-approve

echo "=== Cleanup complete ==="
echo "Note: S3 buckets and DynamoDB table preserved for reuse."
echo "To delete them manually run:"
echo "  aws s3 rb s3://taskapp-terraform-state-${AWS_ACCOUNT_ID} --force"
echo "  aws s3 rb s3://taskapp-kops-state-${AWS_ACCOUNT_ID} --force"
echo "  aws dynamodb delete-table --table-name taskapp-terraform-locks"
