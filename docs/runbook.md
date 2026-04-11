# Operational Runbook

## Deploying the Application

### Full deployment from scratch

1. Bootstrap remote state:
```bash
./scripts/terraform-setup.sh
```

2. Bootstrap Kops state:
```bash
./scripts/kops-setup.sh
```

3. Build AWS infrastructure:
```bash
cd terraform/root
terraform init
terraform apply
```

4. Build Kubernetes cluster:
```bash
kops create -f kops/cluster-config.yaml
kops update cluster --name=${CLUSTER_NAME} --yes
kops validate cluster --wait 20m
```

5. Deploy application:
```bash
kubectl apply -f k8s/
```

6. Install cert-manager and configure SSL:
```bash
./scripts/install-cert-manager.sh
```

7. Run database migrations:
```bash
./scripts/run-migrations.sh
```

---

## Scaling the Cluster

### Scale worker nodes up
```bash
kops edit instancegroup nodes-us-east-1a --name=${CLUSTER_NAME}
# Change maxSize and minSize to desired count
kops update cluster --name=${CLUSTER_NAME} --yes
kops rolling-update cluster --name=${CLUSTER_NAME} --yes
```

### Scale a specific deployment
```bash
kubectl scale deployment frontend --replicas=3 -n taskapp
kubectl scale deployment backend --replicas=3 -n taskapp
```

---

## Rotating Secrets

### Rotate database password
1. Update password in `terraform.tfvars`
2. Apply the change:
```bash
cd terraform/root
terraform apply
```
3. Update the Kubernetes secret:
```bash
kubectl create secret generic db-credentials \
  --from-literal=password=NEW_PASSWORD \
  --dry-run=client -o yaml | kubectl apply -f -
```
4. Restart the backend to pick up the new password:
```bash
kubectl rollout restart deployment/backend -n taskapp
```

### Rotate Kops AWS credentials
1. Run Terraform to generate new access keys:
```bash
cd terraform/root
terraform apply -replace=module.iam.aws_iam_access_key.kops
```
2. Export new credentials:
```bash
export AWS_ACCESS_KEY_ID=$(terraform output kops_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(terraform output -raw kops_secret_access_key)
```

---

## Troubleshooting Common Failures

### Cluster fails to validate
```bash
# Check node status
kubectl get nodes

# Check system pods
kubectl get pods -n kube-system

# Check kops logs
kops validate cluster --name=${CLUSTER_NAME}
```

### Pod stuck in Pending state
```bash
# Describe the pod to see events
kubectl describe pod <pod-name> -n taskapp

# Check if nodes have enough resources
kubectl describe nodes
```

### Database connection failure
```bash
# Check RDS instance status
aws rds describe-db-instances \
  --db-instance-identifier taskapp-postgres \
  --query "DBInstances[0].DBInstanceStatus"

# Check backend logs
kubectl logs deployment/backend -n taskapp
```

### NAT Gateway failure
```bash
# Check NAT Gateway status
aws ec2 describe-nat-gateways \
  --filter "Name=tag:Name,Values=taskapp-nat-*" \
  --query "NatGateways[*].[NatGatewayId,State]" \
  --output table
```

### Node not joining cluster
```bash
# SSH through bastion
ssh -J ubuntu@<bastion-ip> ubuntu@<node-private-ip>

# Check kubelet status on node
sudo systemctl status kubelet
sudo journalctl -u kubelet -n 50
```

### Frontend API calls failing
```bash
# Rebuild frontend with correct API URL
./scripts/build-push.sh

# Update deployment
kubectl set image deployment/frontend \
  frontend=enzoputachi/taskapp-frontend:1.0.2 -n taskapp

kubectl rollout status deployment/frontend -n taskapp
```

### SSL certificate not ready
```bash
# Check certificate status
kubectl get certificate -n taskapp

# Check challenges
kubectl get challenges -n taskapp

# Describe for details
kubectl describe certificate taskapp-tls -n taskapp
```

---

## Destroying the Infrastructure

```bash
./scripts/cleanup.sh
```

This deletes in the correct order:
1. Kops cluster — EC2 instances, load balancers
2. Terraform infrastructure — VPC, NAT Gateways, RDS, IAM

Note: S3 buckets and DynamoDB table are preserved for reuse.
To delete them permanently, see comments inside `cleanup.sh`.

---

## Every Rebuild Workflow

### Step 1 — Rebuild infrastructure
```bash
cd ~/taskapp-capstone/terraform/root
terraform apply
```

### Step 2 — Get new values and replace them

**VPC and subnet IDs in `kops/cluster-config.yaml`:**
```bash
terraform output vpc_id
terraform output private_subnet_ids
terraform output public_subnet_ids
```
Manually replace in `kops/cluster-config.yaml`

**RDS endpoint in `k8s/secrets.yaml`:**
```bash
terraform output db_endpoint
```
Manually replace `DB_HOST` and `DATABASE_URL` in `k8s/secrets.yaml`

**Kops credentials:**
```bash
terraform output kops_access_key_id
terraform output -raw kops_secret_access_key
```
Export them:
```bash
export AWS_ACCESS_KEY_ID=<value>
export AWS_SECRET_ACCESS_KEY=<value>
```

### Step 3 — Rebuild cluster
```bash
kops create -f kops/cluster-config.yaml
kops update cluster --name=${CLUSTER_NAME} --yes
kops validate cluster --wait 20m
```

### Step 4 — Redeploy application
```bash
kubectl apply -f k8s/
./scripts/install-cert-manager.sh
./scripts/run-migrations.sh
```

---

## What Never Changes
- S3 bucket names
- DynamoDB table name
- Domain name
- Docker images
- `CLUSTER_NAME`
- `KOPS_STATE_STORE`
- Database password

---

## Building and Pushing Docker Images

### Using the build script
```bash
./scripts/build-push.sh
```

### Backend image
```bash
docker build -t enzoputachi/taskapp-backend:1.0.0 \
  ~/capstone-project-novara/taskapp_backend
docker push enzoputachi/taskapp-backend:1.0.0
```

### Frontend image (VITE_API_URL required at build time)
```bash
cd ~/capstone-project-novara/taskapp_frontend
docker build --no-cache \
  --build-arg VITE_API_URL=https://api.enzoputachi.site/api \
  -t enzoputachi/taskapp-frontend:1.0.2 .
docker push enzoputachi/taskapp-frontend:1.0.2
```

The `VITE_API_URL` build arg is required — without it the frontend
will default to localhost and API calls will fail in production.

---

## Live URLs
- Frontend: https://taskapp.enzoputachi.site
- Backend API: https://api.enzoputachi.site/api
- Health check: https://api.enzoputachi.site/api/health