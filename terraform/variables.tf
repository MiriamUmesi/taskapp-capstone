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
