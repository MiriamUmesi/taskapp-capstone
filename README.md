# TaskApp — Production Kubernetes Deployment on AWS

A production-grade deployment of TaskApp (React frontend, Flask backend, PostgreSQL) on AWS using Kubernetes, Terraform, and Kops.

## Architecture Overview

- **VPC** — Private network across 3 Availability Zones
- **Kubernetes** — Multi-master cluster managed by Kops
- **Database** — AWS RDS PostgreSQL with Multi-AZ failover
- **DNS** — Route53 with SSL via cert-manager
- **IaC** — All infrastructure defined in Terraform

## Project Structure

```
taskapp-capstone/
├── ansible/       # Node hardening and configuration
├── docs/          # Architecture, runbook, cost analysis
├── k8s/           # Kubernetes manifests
├── kops/          # Cluster configuration
├── scripts/       # Automation scripts
└── terraform/     # AWS infrastructure
    ├── modules/   # vpc, iam, rds, dns, billing
    └── root/      # Entry point
```

## Quickstart

### Prerequisites
- AWS CLI configured
- Terraform >= 1.0
- Kops installed
- kubectl installed

### Step 1 — Bootstrap remote state
```bash
./scripts/terraform-setup.sh
```

### Step 2 — Bootstrap Kops state store
```bash
./scripts/kops-setup.sh
```

### Step 3 — Build AWS infrastructure
```bash
cd terraform/root
terraform init
terraform apply
```

### Step 4 — Build Kubernetes cluster
```bash
kops create -f kops/cluster-config.yaml
kops update cluster --name=${CLUSTER_NAME} --yes
kops validate cluster --wait 20m
```

### Step 5 — Deploy application
```bash
kubectl apply -f k8s/
```

### Teardown
```bash
./scripts/cleanup.sh
```

## Live URLs
- Frontend: https://taskapp.yourdomain.com
- Backend API: https://api.yourdomain.com

## Documentation
- [Architecture](docs/architecture.md)
- [Runbook](docs/runbook.md)
- [Cost Analysis](docs/cost-analysis.md)

```

---
