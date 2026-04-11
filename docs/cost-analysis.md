# Cost Analysis

## Monthly Cost Estimate

All prices based on AWS us-east-1 region pricing.

### Compute — EC2 Instances

| Resource | Type | Count | Unit Price | Monthly |
|----------|------|-------|------------|---------|
| Master nodes | t3.medium | 3 | $0.0416/hr | $91.12 |
| Worker nodes | t3.medium | 3 | $0.0416/hr | $91.12 |
| Bastion host | t3.micro | 1 | $0.0104/hr | $7.49 |

**Subtotal: $189.73**

### Networking

| Resource | Count | Unit Price | Monthly |
|----------|-------|------------|---------|
| NAT Gateway | 3 | $0.045/hr | $98.55 |
| NAT Gateway data | ~100GB | $0.045/GB | $4.50 |
| Load Balancer (API) | 1 | $0.008/hr | $5.84 |
| Elastic IPs | 3 | $0.005/hr | $10.95 |

**Subtotal: $119.84**

### Database — RDS PostgreSQL

| Resource | Type | Monthly |
|----------|------|---------|
| RDS instance | db.t3.micro Single-AZ | $13.87 |
| Storage | 20GB gp3 | $2.30 |
| Backup storage | 20GB | $0.10 |

**Subtotal: $16.27**

### Storage — S3

| Resource | Monthly |
|----------|---------|
| Terraform state bucket | $0.02 |
| Kops state bucket | $0.05 |
| etcd backups | $0.50 |

**Subtotal: $0.57**

### DNS — Route53

| Resource | Monthly |
|----------|---------|
| Hosted zone | $0.50 |
| DNS queries | $0.40 |

**Subtotal: $0.90**

---

## Total Estimated Monthly Cost

| Category | Monthly |
|----------|---------|
| Compute | $189.73 |
| Networking | $119.84 |
| Database | $16.27 |
| Storage | $0.57 |
| DNS | $0.90 |
| **Total** | **$327.31** |

---

## Cost Optimisation Opportunities

### Spot instances (+5% bonus objective)
Replacing worker nodes with spot instances reduces compute cost by ~70%.
Worker node cost drops from $91.12 to approximately $27.34/month.
Total saving: ~$63.78/month.

### Single NAT Gateway
NAT Gateways are the largest cost driver. Using one NAT Gateway instead
of three saves ~$65/month but introduces a single point of failure.
Not recommended for production.

### Reserved Instances
Committing to 1-year reserved instances reduces EC2 costs by ~40%.
Recommended once the architecture is stable.
Estimated saving: ~$75.89/month on compute alone.

---

## Budget Alert

A $50 monthly budget alert is configured in Terraform via the billing
module. Alerts are sent at:
- 80% of limit ($40) — actual spend
- 100% of limit ($50) — forecasted spend

Note: The estimated monthly cost of $327.31 significantly exceeds the
$50 alert threshold. The alert serves as an early warning for unexpected
cost spikes rather than a hard limit on spending.