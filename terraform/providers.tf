terraform {
  backend "s3" {
    bucket         = "taskapp-terraform-state-418884736531"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "taskapp-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
