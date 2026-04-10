variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "domain_name" {
  description = "Your registered domain name e.g. yourdomain.com"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}
