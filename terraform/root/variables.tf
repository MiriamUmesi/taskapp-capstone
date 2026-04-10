variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "taskapp"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "alert_email" {
  description = "Email address for billing alerts"
  type        = string
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Your registered domain name"
  type        = string
}
