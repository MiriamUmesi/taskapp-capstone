module "billing" {
  source            = "../modules/billing"
  project_name      = var.project_name
  alert_email       = var.alert_email
  monthly_limit_usd = 50
}