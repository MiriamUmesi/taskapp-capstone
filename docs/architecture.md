# Architecture Documentation

## System Overview

TaskApp is deployed on a production-grade Kubernetes cluster on AWS, built with high availability, security, and scalability as core principles.

## Network Architecture

### VPC Design
- **CIDR:** `10.0.0.0/16` — chosen to provide 65,536 addresses, sufficient for cluster growth
- **Region:** `us-east-1`
- **Availability Zones:** `us-east-1a`, `us-east-1b`, `us-east-1c`

### Subnet Layout
| Subnet | CIDR | Type | AZ |
|--------|------|------|----|
| public-1a | 10.0.1.0/24 | Public | us-east-1a |
| public-1b | 10.0.2.0/24 | Public | us-east-1b |
| public-1c | 10.0.3.0/24 | Public | us-east-1c |
| private-1a | 10.0.4.0/24 | Private | us-east-1a |
| private-1b | 10.0.5.0/24 | Private | us-east-1b |
| private-1c | 10.0.6.0/24 | Private | us-east-1c |

### Traffic Flow
- **Inbound:** Internet → Load Balancer (public subnet) → Kubernetes nodes (private subnet)
- **Outbound:** Kubernetes nodes → NAT Gateway (public subnet) → Internet

### NAT Gateways
One NAT Gateway per AZ. If one AZ fails, the other two continue operating independently. This eliminates NAT as a single point of failure.

## Kubernetes Architecture

### Control Plane
- 3 master nodes — one per AZ
- etcd distributed across all 3 masters with automated S3 backups
- API server exposed via Network Load Balancer

### Worker Nodes
- 3 worker nodes — one per AZ
- Instance type: t3.micro
- All nodes in private subnets — no public IPs

### Networking
- CNI: Calico — supports NetworkPolicy for pod-level security
- Topology: Private — all nodes hidden from internet
- Bastion host for SSH access

## Database Architecture

### RDS PostgreSQL
- Multi-AZ deployment — automatic failover to standby
- Storage: gp3 encrypted EBS
- Automated backups — 7 day retention
- Placed in private subnets — not accessible from internet
- Security group restricts access to port 5432 from within VPC only

## Security Model

### Network Security
- All Kubernetes nodes in private subnets
- No direct internet access to nodes
- Security groups follow least-privilege principle
- Calico NetworkPolicy for pod-to-pod traffic control

### IAM
- Dedicated `taskapp-kops` IAM user for cluster creation
- Instance profiles for EC2 nodes — no hardcoded credentials
- No root account usage

### Secrets
- Database credentials stored in `terraform.tfvars` — excluded from Git via `.gitignore`
- Kubernetes secrets encrypted at rest

## High Availability Strategy

| Component | HA Mechanism |
|-----------|-------------|
| Masters | 3 nodes across 3 AZs — survives loss of 1 |
| Workers | 3 nodes across 3 AZs — survives loss of 1 |
| Database | RDS Multi-AZ — automatic failover |
| NAT | One per AZ — no shared dependency |
| etcd | Distributed quorum — survives loss of 1 member |

## Infrastructure as Code

All AWS resources are defined in Terraform modules:
- `modules/vpc` — networking
- `modules/iam` — access management
- `modules/rds` — database
- `modules/dns` — Route53
- `modules/billing` — cost alerts

State stored remotely in S3 with DynamoDB locking.
