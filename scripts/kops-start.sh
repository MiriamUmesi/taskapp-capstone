#!/bin/bash

echo "=== Setting Kops AWS credentials ==="
export AWS_ACCESS_KEY_ID=AKIAWDB3Z2YJ54KMLLI5
export AWS_SECRET_ACCESS_KEY=$(cd ~/taskapp-capstone/terraform/root && terraform output -raw kops_secret_access_key)

echo "=== Creating Kops cluster ==="
kops create cluster \
  --name=taskapp.k8s.local \
  --state=s3://taskapp-kops-state-418884736531 \
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
  --network-id=vpc-039c8217b3e046442 \
  --subnets=subnet-0b536e78469c7c02b,subnet-097c007897b237e17,subnet-05196dd9a77d932b8 \
  --utility-subnets=subnet-0e3bcd27861ee737e,subnet-0166cfa46e09374b2,subnet-0fe5b55de902198b9 \
  --ssh-public-key=~/.ssh/taskapp-kops.pub \
  --kubernetes-version=1.31.0 \
  --yes

echo "=== Updating cluster ==="
kops update cluster \
  --name=taskapp.k8s.local \
  --state=s3://taskapp-kops-state-418884736531 \
  --yes --admin

echo "=== Validating cluster ==="
kops validate cluster \
  --name=taskapp.k8s.local \
  --state=s3://taskapp-kops-state-418884736531 \
  --wait 20m

echo "=== Cluster is ready ==="
kubectl get nodes
