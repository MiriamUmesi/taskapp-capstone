module "billing" {
  source            = "../modules/billing"
  project_name      = var.project_name
  alert_email       = var.alert_email
  monthly_limit_usd = 50
}

module "rds" {
  source             = "../modules/rds"
  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  db_password        = var.db_password
}