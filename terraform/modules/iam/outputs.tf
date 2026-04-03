output "kops_access_key_id" {
  description = "Access key ID for Kops user"
  value       = aws_iam_access_key.kops.id
}

output "kops_secret_access_key" {
  description = "Secret access key for Kops user"
  value       = aws_iam_access_key.kops.secret
  sensitive   = true
}

output "kops_user_arn" {
  description = "ARN of the Kops IAM user"
  value       = aws_iam_user.kops.arn
}
