output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "kops_access_key_id" {
  value = module.iam.kops_access_key_id
}

output "kops_secret_access_key" {
  value     = module.iam.kops_secret_access_key
  sensitive = true
}
