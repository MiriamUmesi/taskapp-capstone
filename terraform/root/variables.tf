
variable "alert_email" {
  description = "Email address for billing alerts"
  type        = string
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}
