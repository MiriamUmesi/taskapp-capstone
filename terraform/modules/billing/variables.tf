variable "project_name" {
  description = "Name prefix for all resources"
  type = string
}
variable "alert_email" {
  description = "Email address to receive billing alerts"
  type = string
}
variable "monthly_limit_usd" {
  description = "Monthly budget limit in USD"
  type = number
  default = 50
}
