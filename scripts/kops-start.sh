#!/bin/bash
source $(dirname "$0")/../config.env

echo "=== Setting Kops AWS credentials ==="
export AWS_ACCESS_KEY_ID=$(cd ~/taskapp-client-dobsi894/terraform/root && terraform output -raw kops_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(cd ~/taskapp-client-dobsi894/terraform/root && terraform output -raw kops_secret_access_key)

VPC_ID=$(cd ~/taskapp-client-dobsi894/terraform/root && terraform output -raw vpc_id)
PRIVATE_SUBNETS=$(cd ~/taskapp-client-dobsi894/terraform/root && terraform output -json private_subnet_ids | jq -r 'join(",")')
PUBLIC_SUBNETS=$(cd ~/taskapp-client-dobsi894/terraform/root && terraform output -json public_subnet_ids | jq -r 'join(",")')

echo "=== Creating Kops cluster ==="
kops create cluster \
  --name=${CLUSTER_NAME} \
  --state=${KOPS_STATE_STORE} \
  --cloud=aws \
  --control-plane-count=3 \
  --control-plane-size=t3.medium \
  --node-count=3 \
  --node-size=t3.medium \
  --zones=us-east-1a,us-east-1b,us-east-1c \
  --control-plane-zones=us-east-1a,us-east-1b,us-east-1c \
  --networking=calico \
  --topology=private \
  --bastion \
  --network-id=vpc-087a075fd83d6b979 \
  --subnets=subnet-0380fbdaf66d5186d,subnet-0f30f19f1d8b11e3e,subnet-0d10cb7963cb0845d \
  --utility-subnets=subnet-03ed2302798b4715b,subnet-07134ccddc01f162d,subnet-010348748b277184f \
  --ssh-public-key=~/.ssh/taskapp-kops.pub \
  --kubernetes-version=1.31.0 \
  --yes

echo "=== Updating cluster ==="
kops update cluster \
  --name=${CLUSTER_NAME} \
  --state=${KOPS_STATE_STORE} \
  --yes --admin

echo "=== Validating cluster ==="
kops validate cluster \
  --name=${CLUSTER_NAME} \
  --state=${KOPS_STATE_STORE} \
  --wait 20m

echo "=== Cluster is ready ==="
kubectl get nodes
