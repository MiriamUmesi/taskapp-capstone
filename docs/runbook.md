# Operational Runbook

## Live URLs
- Frontend: https://taskapp.miriamrejoiceumesi.online
- Backend API: https://api.miriamrejoiceumesi.online/api
- Health check: https://api.miriamrejoiceumesi.online/api/health

---

## Full Deployment From Scratch

### Step 1 — Bootstrap remote state
```bash
./scripts/terraform-setup.sh
```

### Step 2 — Bootstrap Kops state
```bash
./scripts/kops-setup.sh
```

### Step 3 — Build AWS infrastructure
```bash
cd ~/taskapp-capstone/terraform/root
terraform init
terraform apply
```

### Step 4 — Create and validate cluster
```bash
./scripts/kops-start.sh
```
This script:
- Sets Kops AWS credentials
- Creates a 3-master, 3-worker cluster across 3 AZs
- Updates and validates the cluster
- Waits up to 20 minutes for the cluster to be ready

### Step 5 — Deploy application, ingress, and cert-manager
```bash
./scripts/kubernetes.sh
```
This script:
- Installs NGINX ingress controller
- Installs cert-manager and waits for it to be ready
- Deploys namespace, secrets, cluster issuer
- Deploys backend, frontend, and ingress

### Step 6 — Run database migrations
```bash
./scripts/run-migrations.sh
```

### Step 7 — Build and push Docker images (if needed)
```bash
./scripts/build-push.sh
```

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

### Step 3 — Recreate cluster
```bash
./scripts/kops-start.sh
```

### Step 4 — Redeploy application
```bash
./scripts/kubernetes.sh
```

### Step 5 — Run database migrations
```bash
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

### Backend image (manual)
```bash
docker build -t miriamumesi/taskapp-backend:1.0.0 \
  ~/capstone-project-novara/taskapp_backend
docker push miriamumesi/taskapp-backend:1.0.0
```

### Frontend image (manual — VITE_API_URL required at build time)
```bash
cd ~/capstone-project-novara/taskapp_frontend
docker build --no-cache \
  --build-arg VITE_API_URL=https://api.miriamrejoiceumesi.online/api \
  -t miriamumesi/taskapp-frontend:1.0.2 .
docker push miriamumesi/taskapp-frontend:1.0.2
```
The `VITE_API_URL` build arg is required — without it the frontend
will default to localhost and API calls will fail in production.

---

## Scaling the Cluster

### Scale worker nodes
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
kubectl get nodes
kubectl get pods -n kube-system
kops validate cluster --name=${CLUSTER_NAME}
```

### Pod stuck in Pending state
```bash
kubectl describe pod <pod-name> -n taskapp
kubectl describe nodes
```

### Database connection failure
```bash
aws rds describe-db-instances \
  --db-instance-identifier taskapp-postgres \
  --query "DBInstances[0].DBInstanceStatus"

kubectl logs deployment/backend -n taskapp
```

### NAT Gateway failure
```bash
aws ec2 describe-nat-gateways \
  --filter "Name=tag:Name,Values=taskapp-nat-*" \
  --query "NatGateways[*].[NatGatewayId,State]" \
  --output table
```

### Node not joining cluster
```bash
ssh -J ubuntu@<bastion-ip> ubuntu@<node-private-ip>
sudo systemctl status kubelet
sudo journalctl -u kubelet -n 50
```

### Frontend API calls failing
```bash
./scripts/build-push.sh
kubectl set image deployment/frontend \
  frontend=miriamumesi/taskapp-frontend:1.0.2 -n taskapp
kubectl rollout status deployment/frontend -n taskapp
```

### SSL certificate not ready
```bash
kubectl get certificate -n taskapp
kubectl get challenges -n taskapp
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