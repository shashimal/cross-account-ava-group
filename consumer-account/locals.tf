locals {
  app_name = "shared-ava-group"
  application_domain     = "app.ava.duleendra.com"

  #VPC
  azs              = ["us-east-1a", "us-east-1b"]
  cidr             = "20.0.0.0/16"
  private_subnets  = ["20.0.0.0/19", "20.0.32.0/19"]
  public_subnets   = ["20.0.64.0/19", "20.0.96.0/19"]
  database_subnets = ["20.0.128.0/19", "20.0.160.0/19"]
}